require 'nitrous/progress_bar'
module Nitrous
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
end