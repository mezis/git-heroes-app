module Debug
  class HeapDumpJob < BaseJob
    def perform(options = {})
      Debug::HeapDump.call
    end
  end
end
