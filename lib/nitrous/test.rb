require 'core_ext'
require 'nitrous/assertions'
require 'nitrous/test_block'
require 'nitrous/test_context'
require 'nitrous/test_result'
module Nitrous
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
          context.finish
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
end