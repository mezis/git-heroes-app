Sidekiq.configure_client do |config|
  config.redis = { redis: Rails.application.redis }
end
Sidekiq.configure_server do |config|
  config.redis = { redis: Rails.application.redis }
end
