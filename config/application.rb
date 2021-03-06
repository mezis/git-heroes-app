require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Monkey patching here so there aren't duplicate lines in console/server
# https://github.com/rails/rails/issues/11415#issuecomment-57648388
ActiveSupport::Logger.class_eval do 
  def self.broadcast(logger) 
    Module.new do
    end
  end
end

# Set up load path
File.expand_path('../../lib', __FILE__).tap { |d| $:.unshift(d) unless $:.include?(d) }
require 'git_heroes/redis_connection'

module GitHeroes
  class Application < Rails::Application
    include RedisConnection

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Be sure to have the adapter's gem in your Gemfile
    # and follow the adapter's specific installation
    # and deployment instructions.
    config.active_job.queue_adapter = :sidekiq

    # Do log asset requests in production
    config.quiet_assets = false

    # Set up caching
    if ENV.fetch('CACHE_ENABLED', 'YES') =~ /ON|TRUE|YES|1/i
      config.cache_store = :level2, {
        L1: [
          :memory_store, size: 32.megabytes,
        ],
        L2: [
          :redis_store, pool: redis_cache_pool, expires_in: 1.day,
        ]
      }
    else
      config.cache_store = nil
    end

    # Cache public assets
    config.static_cache_control = 'public, max-age=31536000'

    # Configure ActionMailer
    config.action_mailer.default_url_options = { host: ENV.fetch('HOSTNAME') }

  end
end
