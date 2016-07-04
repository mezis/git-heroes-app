class GcJob < BaseJob
  def perform(options = {})
    GC.start
  end
end
