class SerializationService
  def dump(data)
    JSON.dump(transform(data))
  end

  def load(string)
    untransform(JSON.load(string))
  rescue => e
    binding.pry
  end

  protected

  # convert records to GlobalIDs
  def transform(data)
    case data
    when Hash 
      data.each_with_object({}) do |(key,value),h|
        h[transform(key)] = transform(value)
      end
    when Array
      data.map { |x| transform(x) }
    when ActiveRecord::Base
      GlobalID.create(data).to_s
    when Symbol
      "__symbol_#{data}__"
    else
      data
    end
  end

  def untransform(data)
    case data
    when Hash 
      data.each_with_object({}) do |(key,value),h|
        h[untransform(key)] = untransform(value)
      end
    when Array
      data.map { |x| untransform(x) }
    when %r{^gid://}
      GlobalID.find(data)
    when %r{^__symbol_(.*)__$}
      $1.to_sym
    else
      data
    end
  end

end
