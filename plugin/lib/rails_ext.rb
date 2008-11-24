unless ActiveRecord::Base.instance_methods.include?('save_with_tracking')
  class ActiveRecord::Base
    cattr_accessor :saved_objects
    cattr_accessor :invalid_objects
    cattr_accessor :destroyed_objects
    
    def create_or_update_with_tracking(*args)
      new_record = new_record?
      saved = create_or_update_without_tracking(*args)
      append_instance(ActiveRecord::Base.saved_objects) if new_record && saved
      saved
    end
    alias_method_chain :create_or_update, :tracking

    def destroy_with_tracking(*args)
      result = destroy_without_tracking(*args)
      append_instance(ActiveRecord::Base.destroyed_objects) if result
      result
    end
    alias_method_chain :destroy, :tracking
    
    def validate_with_tracking(*args)
      valid = validate_without_tracking(*args)
      append_instance(ActiveRecord::Base.invalid_objects) if !valid
      valid
    end
    alias_method_chain :validate, :tracking
    
    private
      def append_instance(list)
        return if !list
        key = self.class.name.underscore.to_sym
        list[key] ||= []
        list[key] << self
      end
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