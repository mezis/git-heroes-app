require 'rspec'
require 'hashie'

module LoadJSONExample
  def load_sample(name, as: :hashie)
    raw = File.read "spec/fixtures/responses/#{name}.json"

    return raw if as == :raw

    data = JSON.parse(raw)
    return data if as == :json

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
