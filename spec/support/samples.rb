require 'rspec'
require 'hashie'

module LoadJSONExample
  def load_sample(name)
    Hashie::Mash.new JSON.parse File.read "spec/data/#{name}.json"
  end
end

RSpec.configure do |conf|
  conf.include LoadJSONExample
end
