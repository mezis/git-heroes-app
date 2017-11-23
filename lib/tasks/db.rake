namespace :db do
  desc 'Pull production database into local dev database'
  task :pull => :drop do
    ENV.each_key do |k|
      next unless k =~ /^(BUNDLE|GEM|RUBY)/
      ENV.delete(k)
    end
    system 'heroku pg:pull DATABASE_URL postgres:///gh_dev'
  end

  def anonymise(model, field)
    model.find_each do |r|
      begin
        r.update_attributes! field => yield
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end

  desc 'Anonymises default database'
  task :anon => :environment do
    raise 'probably not in production!' if Rails.env.production?
    require 'faker'
    anonymise(Organisation, :name)  { Faker::App.name }
    anonymise(User, :login)         { Faker::Internet.user_name }
    anonymise(Repository, :name)    { Faker::Hacker.ingverb }
    anonymise(Team, :name)          { Faker::Company.profession }
  end

  desc 'Bulk updates Rails counter caches'
  task :reset_counters => :environment do
    models = {
      Organisation  => %i[users repositories],
      User          => %i[owner_repositories],
      Repository    => %i[users],
      PullRequest   => %i[comments],
    }

    models.each_pair do |model, counters|
      model.pluck(:id).each do |id|
        model.reset_counters(id, *counters)
      end
    end

  end
end
