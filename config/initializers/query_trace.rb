if ENV.fetch('QUERY_TRACE', 'OFF') =~ /ON|TRUE|1/i
  ActiveRecordQueryTrace.level = :app
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.lines = 5
end

