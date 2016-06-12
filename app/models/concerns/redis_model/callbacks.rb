module RedisModel
  module Callbacks
    extend ActiveSupport::Concern
    include Attributable

    attr_reader :_callbacks

    def initialize(options = {})
      super
      @_callbacks ||= {}
    end

    def after_destroy(job_class, *argv)
      (@_callbacks[:after_destroy] ||= []) << [job_class, *argv]
    end

    def destroy
      super do |m|
        m.after_multi { run_callbacks(:after_destroy) }
        yield m if block_given?
      end
    end

    protected

    def attribute_names
      super + %i[_callbacks]
    end

    private

    def run_callbacks(name)
      @_callbacks[name]&.each do |job_class, *args|
        job_class.perform_later(*args)
      end
    end
  end
end

