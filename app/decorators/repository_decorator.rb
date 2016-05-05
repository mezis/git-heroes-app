class RepositoryDecorator < SimpleDelegator
  attr_reader :contributors

  def initialize(object, contributors:[])
    @contributors = contributors
    super object
  end
end
