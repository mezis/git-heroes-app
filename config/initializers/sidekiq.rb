Sidekiq.configure_client do |config|
  config.redis = Rails.application.redis_sidekiq_pool
end
Sidekiq.configure_server do |config|
  config.redis = Rails.application.redis_sidekiq_pool
end
