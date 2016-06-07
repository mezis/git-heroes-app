ActiveSupport::Notifications.subscribe 'cache_read.active_support' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if name = event.payload[:name]
    hit_or_miss = event.payload[:hit] ? 'hits' : 'misses'
    Appsignal.increment_counter("cache.#{name}.#{hit_or_miss}", 1)
  end
end

ActiveSupport::Notifications.subscribe 'cache_write.active_support' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  if name = event.payload[:name]
    Appsignal.increment_counter("cache.#{name}.writes", 1)
  end
end
