unless Object.instance_methods(false).include?(:transform_values)
  class Object
    def transform_values
      map do |k,v|
        [k, (yield v)]
      end.to_h
    end
  end
end

module MashToHash
  def convert_to_hash(el)
    case el
    when Mash
      el.transform_values do |value|
        convert_to_hash(value)
      end
    when Array
      el.map do |value|
        convert_to_hash(value)
      end
    else
      el
    end
  end
end
