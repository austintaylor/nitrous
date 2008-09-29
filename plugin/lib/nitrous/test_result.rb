module Nitrous
  class TestResult
    attr_reader :errors
    def initialize(test)
      @test, @errors = test, []
    end

    def to_s
      %{#{@test}: #{pass_fail_skip}}
    end

    def pass_fail_skip
      return "Skipped" if @test.skip?
      @errors.empty? ? "Passed" : "Failed"
    end
  end
end