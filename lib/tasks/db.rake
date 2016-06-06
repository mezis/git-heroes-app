namespace :db do
  task :pull => :drop do
    ENV.each_key do |k|
      next unless k =~ /^(BUNDLE|GEM|RUBY)/
      ENV.delete(k)
    end
    system 'heroku pg:pull DATABASE_URL postgres://localhost/gh_dev'
  end
end
