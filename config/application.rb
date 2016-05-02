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

module GitHeroes
  class Application < Rails::Application
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
    config.active_job.queue_adapter = :resque

    # Do log asset requests in production
    config.quiet_assets = false

    def redis
      @redis ||= begin
        uri = URI.parse(ENV.fetch('REDIS_URL'))
        _, db, namespace = uri.path&.split('/')
        db ||= 1
        namespace ||= 'githeroes'
        uri.path = "/#{db}"
        Redis::Namespace.new(namespace, deprecations: true, redis: Redis.new(url: uri.to_s))
      end
    end

    def locks
      @_locks ||= Redlock::Client.new([redis])
    end
  end
end
