RSpec.configure do |config|
  # clean out the queue before each spec
  config.before(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end
end
