require 'rspec'
require 'hashie'

module LoadJSONExample
  def load_sample(name)
    data = JSON.parse File.read "spec/fixtures/responses/#{name}.json"
    case data
    when Array
      data.map { |x| Hashie::Mash.new(x) }
    else
      Hashie::Mash.new(data)
    end
  end
end

RSpec.configure do |conf|
  conf.include LoadJSONExample
end
