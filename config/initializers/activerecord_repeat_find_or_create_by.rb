module ActiveRecordRepeatFindOrCreateBy
  def find_or_create_by_with_retry!(*args, &block)
    find_or_create_by_without_retry!(*args, &block)
  rescue ActiveRecord::RecordNotUnique
    find_or_create_by_without_retry!(*args, &block)
  end
end

ActiveRecord::Relation.class_eval do
  include ActiveRecordRepeatFindOrCreateBy

  alias_method_chain :find_or_create_by!, :retry
end
