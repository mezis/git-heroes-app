RSpec.configure do |config|
  config.before(:each) do
    Rails.application.redis.flushdb
  end
end
