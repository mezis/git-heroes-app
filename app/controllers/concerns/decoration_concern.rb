module DecorationConcern
  def decorate(resource)
    case resource
    when Array
      resource.map { |r| decorate r }
    else
      "#{resource.class.name}Decorator".constantize.new(resource)
    end
  end
end
