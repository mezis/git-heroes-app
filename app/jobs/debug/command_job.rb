module Debug
  class CommandJob < BaseJob
    def perform(options = {})
      command = options.fetch(:command, 'date')
      system command
    end
  end
end
