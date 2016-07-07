module Debug
  class ClearCachesJob < BaseJob
    def perform(options = {})
      Rails.cache.stores.each(&:clear)
    end
  end
end
