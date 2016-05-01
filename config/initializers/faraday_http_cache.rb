
# Subscribes to all events from Faraday::HttpCache.
ActiveSupport::Notifications.subscribe "http_cache.faraday" do |*args|
  # Rails.logger.info args.inspect
  event = ActiveSupport::Notifications::Event.new(*args)
  cache_status = event.payload[:cache_status]
  env = event.payload[:env]
  Rails.logger.debug("http cache: #{cache_status.upcase} on #{env.method.upcase} #{env.url}")
end
