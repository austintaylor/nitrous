require 'nitrous/progress_bar'
module Nitrous
  class TestContext
    def self.textmate?
      !!ENV["TM_MODE"]
    end
    
    def self.create(test_count)
      if textmate?
        TestContext.new(test_count)
      else
        CommandLineTestContext.new(test_count)
      end
    end
    
    def initialize(test_count)
      @start_time = Time.now
      @total, @failures, @test = test_count, 0, 0
    end

    def ran_test(test)
      @test += 1
    end

    def failed
      @failures += 1
    end
    
    def finish
      puts summary_with_benchmark
    end
    
    def summary
      "Test #{@test} of #{@total} -- #{@failures} failures"
    end
    
    def summary_with_benchmark
      summary + " -- #{Time.now - @start_time} seconds"
    end
  end
  
  class CommandLineTestContext < TestContext
    def initialize(test_count)
      super
      @progress_bar = ProgressBar.new(test_count)
      update_text
    end
    
    def ran_test(test)
      super
      @progress_bar.step
      update_text
    end
    
    def update_text
      @progress_bar.text = summary
    end
    
    def failed
      super
      @progress_bar.color = ProgressBar::RED
    end
    
    def finish
      @progress_bar.text = summary_with_benchmark
      @progress_bar.draw
    end
  end
end