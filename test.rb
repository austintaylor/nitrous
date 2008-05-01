require 'lib/core_ext'
require 'lib/progress_bar'

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
  
  def assert_equal!(expected, actual)
    fail("Expected: <#{expected}> but was <#{actual}>") unless expected == actual
  end
  
  def assert_raise!(type=Exception, &block)
    yield
    passed = true
  rescue type
    fail("Expected a(n) #{type} to be raised") if passed
  end
end

class Test
  include Assertions
  def self.tests
    @tests ||= []
  end

  def self.test(name=nil, &block)
    self.tests << TestBlock.new(name, block)
  end
  
  def self.inherited(subclass)
    if !@test_classes
      @test_classes = []
      at_exit do
        context = TestContext.new(@test_classes.sum {|klass| klass.tests.size})
        @test_classes.each do |klass|
          klass.run(context)
        end
      end
    end
    @test_classes << subclass
  end
  
  def self.run(context=TestContext.new)
    self.new(context).run
  end
  
  def initialize(context)
    @context = context
    @test_results = []
  end
  
  def collect_errors
    yield
  rescue Exception
    @test_results.last.errors << $!
    @context.failed
  end
  
  def running(test)
    @test_results << TestResult.new(test)
  end
  
  def run
    self.class.tests.each do |test|
      running(test)
      test.run(self)
      @context.ran_test(test)
    end
    puts @test_results
  end
end

class TestContext
  def initialize(test_count)
    @total, @failures, @test = test_count, 0, 0
    @progress_bar = ProgressBar.new(test_count)
    update_text
  end
  
  def ran_test(test)
    @test += 1
    @progress_bar.step
    update_text
  end
  
  def update_text
    @progress_bar.text = "Test #{@test} of #{@total} -- #{@failures} failures"
  end
  
  def failed
    @failures += 1
    @progress_bar.color = ProgressBar::RED
  end
end

class AssertionFailedError < Exception
  def initialize(message)
    @message = message
  end
  
  def failure_location
    return @failure_location if @failure_location
    backtrace.each_with_index do |line, i|
      if line =~ /test.rb:\d+:in `instance_eval'/
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

class TestBlock
  def initialize(name, block)
    @name, @block = name, block
  end
  
  def run(test)
    test.collect_errors do
      test.instance_eval(&@block)
    end
  end
  
  def to_s
    @name || "anonymous"
  end
end

class TestResult
  attr_reader :errors
  def initialize(test)
    @test, @errors = test, []
  end
  
  def to_s
    %{#{@test}: #{pass_fail}\n#{@errors.map(&:format).join("\n")}}
  end
  
  def pass_fail
    @errors.empty? ? "Passed" : "Failed"
  end
end

# class ChickenTest < Test
#   test do
#     assert false
#     assert! nil
#     assert false
#     assert! true
#   end
#   
#   test "another" do
#   end
# end
# 
# ChickenTest.run