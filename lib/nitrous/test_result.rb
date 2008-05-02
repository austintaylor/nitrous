module Nitrous
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
end