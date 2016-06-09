class FailJob < BaseJob
  def perform(*args)
    Rails.logger.info "FailJob: #{args.inspect}"
    raise 'failing job!'
  end
end
