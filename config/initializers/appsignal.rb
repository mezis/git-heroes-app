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

Thread.new do
  dyno = ENV.fetch('DYNO', 'local').split('.').first
  gauge_name = "process.#{dyno}.rss"
  loop do
    mem_mb = GetProcessMem.new.mb
    Appsignal.set_gauge(gauge_name, mem_mb)
    sleep 30
  end
end
