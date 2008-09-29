unless ActiveRecord::Base.instance_methods.include?('save_with_tracking')
  class ActiveRecord::Base
    cattr_accessor :saved_objects
    cattr_accessor :destroyed_objects
    def save_with_tracking(*args)
      new_record = new_record?
      saved = save_without_tracking(*args)
      if new_record && ActiveRecord::Base.saved_objects && saved
        key = self.class.name.underscore.to_sym
        ActiveRecord::Base.saved_objects[key] ||= []
        ActiveRecord::Base.saved_objects[key] << self
      end
      saved
    end
    alias_method_chain :save, :tracking

    def destroy_with_tracking(*args)
      result = destroy_without_tracking(*args)
      if result && ActiveRecord::Base.destroyed_objects
        key = self.class.name.underscore.to_sym
        ActiveRecord::Base.destroyed_objects[key] ||= []
        ActiveRecord::Base.destroyed_objects[key] << self
      end
      result
    end
    alias_method_chain :destroy, :tracking
  end
end
module Extensions
  module Core
    module Hash
      def to_fields(fields = {}, namespace = nil)
        each do |key, value|
          key = namespace ? "#{namespace}[#{key}]" : key
          case value
          when ::Hash
            value.to_fields(fields, key)
          when ::Array
            fields["#{key}[]"] = value
          else
            fields[key.to_s] = value
          end
        end
        fields
      end
    end
  end
end
Hash.send :include, Extensions::Core::Hash