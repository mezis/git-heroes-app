if ENV.fetch('QUERY_TRACE', 'OFF') =~ /ON|TRUE|1/i
  require 'active_record_query_trace'
  ActiveRecordQueryTrace.level = :app
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.lines = 5
end

