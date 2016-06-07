ActiveSupport::Notifications.subscribe 'cache_read.active_support' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if event.payload[:hit]
    level = event.payload[:level] || 'any'
    Appsignal.increment_counter("cache_hits_#{level}", 1)
  else
    Appsignal.increment_counter('cache_misses', 1)
  end
end

ActiveSupport::Notifications.subscribe 'cache_write.active_support' do |*args|
  Appsignal.increment_counter("cache_writes", 1)
end
