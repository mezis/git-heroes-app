class RepositoryDecorator < SimpleDelegator
  attr_reader :contributors

  def initialize(object, contributors:[])
    @contributors = contributors
    super object
  end

  def to_ary
    __getobj__.send(:to_ary)
  end
end
