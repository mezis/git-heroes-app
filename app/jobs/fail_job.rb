class FailJob < BaseJob
  def perform(*args)
    Rails.logger.info 'failing!'
    raise 'failing job!'
  end
end
