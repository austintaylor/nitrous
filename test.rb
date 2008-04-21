module Assertions
  def self.method_added(method)
    define_method(method.to_s.gsub("!", '')) do |*args|
      collect_errors do
        send(method, *args)
      end
    end if method.to_s =~ /!$/
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
end

class Test
  include Assertions
  def self.tests
    @tests ||= []
  end

  def self.test(name=nil, &block)
    self.tests << TestBlock.new(name, block)
  end
  
  def self.run
    self.new.run
  end
  
  def initialize
    @test_results = []
  end
  
  def collect_errors
    yield
  rescue Exception
    @test_results.last.errors << $!
  end
  
  def running(test)
    @test_results << TestResult.new(test)
  end
  
  def run
    self.class.tests.each do |test|
      running(test)
      test.run(self)
    end
    puts @test_results
  end
end

class AssertionFailedError < Exception
  def initialize(message)
    @message = message
  end
  
  def to_s
    @message
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
    %{#{@test}: #{pass_fail}\n#{@errors.join("\n")}}
  end
  
  def pass_fail
    @errors.empty? ? "Passed" : "Failed"
  end
end

class ChickenTest < Test
  test do
    assert false
    assert! nil
    assert false
    assert! true
  end
  
  test "another" do
  end
end

ChickenTest.run