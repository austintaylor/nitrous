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
      index = $2.to_i - 1
      lines = File.readlines($1)
      "...\n" + 
      "   " + lines[index - 1] + 
      " >>" + lines[index]     + 
      "   " + lines[index + 1] + 
      "...\n"
    end

    def test_output
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
    
    def self.included(mod)
      mod.module_eval do
        def self.method_added(method)
          Assertions.method_added(method)
        end
      end
    end

    def fail(message)
      raise AssertionFailedError.new(message)
    end

    def assert!(value)
      fail("#{value.inspect} is not true.") unless value
      yield if block_given?
    end

    def assert_nil!(value)
      fail("#{value.inspect} is not nil.") unless value.nil?
      yield if block_given?
    end

    def assert_equal!(expected, actual, message=nil)
      fail(message || "Expected: <#{expected}> but was <#{actual}>") unless expected == actual
      yield if block_given?
    end
    
    def assert_not_equal!(not_expected, actual, message=nil)
      fail(message || "Expected: <#{not_expected}> not to equal <#{actual}>") unless not_expected != actual
      yield if block_given?
    end
    
    def assert_match!(pattern, string, message=nil)
      pattern = Regexp.new(Regexp.escape(pattern)) if pattern.is_a?(String)
      fail("#{string} expected to be =~ #{pattern}") unless string =~ pattern
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