require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.before { WebMock.disable_net_connect! }
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr'
  config.hook_into :webmock
end

