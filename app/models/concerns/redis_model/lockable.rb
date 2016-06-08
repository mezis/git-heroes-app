module RedisModel
  module Lockable
    extend ActiveSupport::Concern
    include Base

    def lock
      Rails.application.locks.lock!(_key_lock, 3_600) { yield self }
    end

    private

    def _key_lock
      _key 'lock', (yield if block_given?)
    end
  end
end
