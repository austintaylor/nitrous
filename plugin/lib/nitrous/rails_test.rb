require 'rails_ext'
module Nitrous
  class RailsTest < Nitrous::Test
    def created(type)
      lookup(type, ActiveRecord::Base.saved_objects)
    end
    
    def assert_created!(type)
      instance = created(type)
      fail("Should have created a #{type}.#{invalid(type) ? " Errors: #{invalid(type).errors.full_messages.to_sentence}" : ''}") unless instance
      yield(instance) if block_given?
      instance
    end
    
    def assert_not_created!(type)
      instance = created(type).reload rescue nil
      fail("Should not have created a #{type}. Instance: #{instance.inspect}") if instance
      yield if block_given?
    end
    
    def invalid(type)
      lookup(type, ActiveRecord::Base.invalid_objects)
    end
    
    def destroyed(type)
      lookup(type, ActiveRecord::Base.destroyed_objects)
    end
    
    private
      def lookup(type, list)
        (list[type] && list[type].last) || list[type.to_s.singularize.to_sym]
      end

      def reset_record_tracking
        ActiveRecord::Base.saved_objects = {}
        ActiveRecord::Base.invalid_objects = {}
        ActiveRecord::Base.destroyed_objects = {}
        @emails = ActionMailer::Base.deliveries.size
      end
    
      def nitrous_setup
        super
        reset_record_tracking
      end
      
      def nitrous_teardown
        ActiveRecord::Base.send(:subclasses).each do |klass|
          klass.delete_all
        end
      end
  end
end