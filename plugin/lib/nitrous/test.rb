require File.dirname(__FILE__) + '/../core_ext'
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

    def self.ztest(name=nil, &block)
      self.tests << TestBlock.new(name, block, true)
    end
    
    def self.exclude(klass)
      @test_classes.delete(klass)
    end

    def self.inherited(subclass)
      class << subclass
        def inherited(subclass)
          Nitrous::Test.exclude(self)
          Nitrous::Test.inherited(subclass)
        end
      end
      if !@test_classes
        @test_classes = []
        at_exit do
          context = TestContext.create(@test_classes.sum {|klass| klass.tests.size})
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

    def nitrous_setup; end
    def nitrous_teardown; end
    def setup; end
    def teardown; end

    def collect_errors
      yield
    rescue Exception
      @test_results.last.errors << $!
      @context.failed($!)
    end

    def running(test)
      @test_results << TestResult.new(test)
    end

    def run
      puts self.class.name
      self.class.tests.each do |test_block|
        running(test_block)
        nitrous_setup
        collect_errors do
          setup
          test_block.run(self)
          teardown
        end
        nitrous_teardown
        @context.ran_test(test_block, @test_results.last)
      end
    end
  end
end