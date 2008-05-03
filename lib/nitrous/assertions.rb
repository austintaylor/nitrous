module Nitrous
  class AssertionFailedError < Exception
    def initialize(message)
      @message = message
    end

    def failure_location
      return @failure_location if @failure_location
      backtrace.each_with_index do |line, i|
        if line =~ /test_block.rb:\d+:in `instance_eval'/
          @failure_location = backtrace[i-1]
          break
        end
      end
     @failure_location
    end

    def snippet
      failure_location =~ /^([^:]+):(\d+)/
      File.readlines($1)[$2.to_i-1]
    end

    def format
      "Assertion failed on #{failure_location}\n#{@message}\n#{snippet}"
    end
  end

  module Assertions
    def self.method_added(method)
      return unless method.to_s =~ /!$/
      name = method.to_s.gsub("!", '')
      module_eval <<-"end;"
        def #{name}(*args, &b)
          collect_errors do
            #{method}(*args, &b)
          end
        end
      end;
    end

    def fail(message)
      raise AssertionFailedError.new(message)
    end

    def assert!(value)
      fail("#{value.inspect} is not true.") unless value
    end

    def assert_nil!(value)
      fail("#{value.inspect} is not nil.") unless value.nil?
    end

    def assert_equal!(expected, actual, message=nil)
      fail(message || "Expected: <#{expected}> but was <#{actual}>") unless expected == actual
    end

    def assert_raise!(type=Exception, &block)
      yield
      passed = true
      raise
    rescue Exception => e
      fail("Expected a(n) #{type} to be raised but raised a(n) #{e.class}") if e.class != type
      fail("Expected a(n) #{type} to be raised") if passed
    end
  end
end