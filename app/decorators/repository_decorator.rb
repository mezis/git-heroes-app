class RepositoryDecorator < SimpleDelegator
  def initialize(object, contributors: nil, contributor_count: nil)
    @contributors = contributors
    @contributor_count = contributor_count
    super object
  end

  def contributors
    return unless @contributors
    @contributors.call
  end

  def contributor_count
    return unless @contributor_count
    @contributor_count.call
  end
end
