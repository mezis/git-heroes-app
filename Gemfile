source 'https://rubygems.org'
ruby '2.3.1'

#
# Rails basics
#

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Faster caching
gem 'level2'


#
# Views
#

# Better view syntax
gem 'haml-rails'

# Less verbose assets
gem 'quiet_assets'

# Chrome
gem 'bootstrap', '~> 4.0.0.alpha3'
gem 'rails-assets-tether'
gem 'font-awesome-rails'
gem 'octicons-rails', git: 'https://github.com/mezis/octicons-rails', branch: 'upstream-pr'

# Graphs!
gem 'chartkick'

# Email CSS inliner
gem 'roadie-rails'

# Nice loading progessbar
gem 'nprogress-rails'


#
# Models
#

# Easy GROUP BY with ActiveRecord
gem 'groupdate'

# Spot missing indices, bad queries
gem 'lol_dba', group: :development
gem 'bullet', group: :development
gem 'active_record_query_trace', require: false

gem 'email_validator'


#
# Controllers
#

# Authentication
gem 'omniauth-github'

# Authorization
gem 'pundit'

# Pagination
gem 'kaminari'


#
# Service layer
#

# Controller services
gem 'interactor'

# HTTP client
gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-http-cache'
gem 'net-http-persistent'

# Github API client
gem 'octokit'

# Business time
gem 'working_hours'

#
# Background jobs
#

gem 'redis-namespace'
gem 'globalid'
gem 'redlock'
gem 'sidekiq'
gem 'sinatra', require:false # for sidekiq's web UI

#
# Caching
#

# Rails, Rack, Session cache
gem 'redis-rails'

#
# Serving & hosting
#

# 12factor support
gem 'dotenv-rails'
gem 'rails_12factor'
gem 'foreman'

# Use Puma as the app server
gem 'puma'

# Peformance / error monitoring
gem 'appsignal'
gem 'appsignal-redis'

# Force SSL usage
gem 'rack-ssl'


#
# Development/test support
#

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Preloader
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'

  # REPLs
  gem 'pry-rails'
  gem 'binding_of_caller'
  gem 'better_errors'

  # Unit/integration testing
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-activejob'

  # Test factories
  gem 'factory_girl_rails'

  # Time travel in tests
  gem 'timecop', require: false

  # Auto runner
  gem 'guard-rspec'

  # Debug logging for HTTP requests
  gem 'httplog', require: false

  # Generate fake data
  gem 'faker', require: false

  # Nice colours on the CLI
  gem 'term-ansicolor', require: false
end

