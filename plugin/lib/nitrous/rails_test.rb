require 'rails_ext'
module Nitrous
  class RailsTest < Nitrous::Test
    def created(type)
      (ActiveRecord::Base.saved_objects[type] && ActiveRecord::Base.saved_objects[type].last) || 
        ActiveRecord::Base.saved_objects[type.to_s.singularize.to_sym]
    end

    def destroyed(type)
      (ActiveRecord::Base.destroyed_objects[type] && ActiveRecord::Base.destroyed_objects[type].last) || 
        ActiveRecord::Base.destroyed_objects[type.to_s.singularize.to_sym]
    end
    
    private
      def reset_record_tracking
        ActiveRecord::Base.saved_objects = {}
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