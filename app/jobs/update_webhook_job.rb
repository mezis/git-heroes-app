class UpdateWebhookJob < BaseJob
  def perform(options = {})
    UpdateWebhook.call organisation: options[:organisation]
  end
end
