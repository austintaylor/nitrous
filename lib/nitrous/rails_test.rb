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

    def assert_email_sent!(count=1, &block)
      assert_equal! @emails + count, ActionMailer::Base.deliveries.size
      block.call(*ActionMailer::Base.deliveries[-count..-1]) if block_given?
    ensure
      @emails = ActionMailer::Base.deliveries.size
    end

    def assert_no_email_sent!(&block)
      assert_equal! @emails, ActionMailer::Base.deliveries.size
      block.call if block_given?
    ensure
      @emails = ActionMailer::Base.deliveries.size
    end

    def invalid(type)
      lookup(type, ActiveRecord::Base.invalid_objects)
    end

    def destroyed(type)
      lookup(type, ActiveRecord::Base.destroyed_objects)
    end

    def assert_destroyed!(type)
      instance = destroyed(type)
      fail("Should have destroyed a #{type}.") unless instance
      yield(instance) if block_given?
      instance
    end

    private
      def lookup(type, list)
        (list[type] && list[type].last) || list[type.to_s.singularize.to_sym]
      end

      def reset_record_tracking
        if defined?(ActiveRecord)
          ActiveRecord::Base.saved_objects = {}
          ActiveRecord::Base.invalid_objects = {}
          ActiveRecord::Base.destroyed_objects = {}
        end
        @emails = ActionMailer::Base.deliveries.size
      end

      def nitrous_setup
        super
        reset_record_tracking
      end

      def nitrous_teardown
        if defined?(ActiveRecord)
          ActiveRecord::Base.send(:subclasses).each do |klass|
            klass.delete_all rescue nil
          end
        end
      end
  end
end
