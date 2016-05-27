class ApplicationModel < ActiveRecord::Base
  self.abstract_class = true

  def find_or_create_by!(*args, &block)
    super
  rescue ActiveRecord::RecordNotUnique
    super
  end
end
