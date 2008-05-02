module Nitrous
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
end