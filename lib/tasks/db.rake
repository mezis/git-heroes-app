namespace :db do
  task :pull => :drop do
    ENV.each_key do |k|
      next unless k =~ /^(BUNDLE|GEM|RUBY)/
      ENV.delete(k)
    end
    system 'heroku pg:pull DATABASE_URL postgres://localhost/gh_dev'
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

  task :anon => :environment do
    raise 'probably not in production!' if Rails.env.production?
    require 'faker'
    anonymise(Organisation, :name)  { Faker::App.name }
    anonymise(User, :login)         { Faker::Internet.user_name }
    anonymise(Repository, :name)    { Faker::Hacker.ingverb }
    anonymise(Team, :name)          { Faker::Company.profession }
  end
end
