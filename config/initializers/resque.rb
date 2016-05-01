require 'resque'
require 'resque-retry'
require 'resque-retry/server'
require 'resque/failure/redis'

Rails.logger.info "setting up resque"

Resque.redis = Rails.application.redis
Resque.redis.namespace = 'githeroes_dev:resque'

# Support class reloading in Resque
# https://github.com/resque/resque/issues/447
unless Rails.application.config.cache_classes
  Resque.after_fork do |job|
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
  end
end

Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

Resque::Scheduler.dynamic = true
Resque.schedule = {}

Resque.logger = Logger.new(STDOUT)

