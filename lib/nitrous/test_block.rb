module Nitrous
  class TestBlock
    def initialize(name, block, skip=false)
      @name, @block, @skip = name, block, skip
    end

    def run(test)
      test.collect_errors do
        test.instance_eval(&@block) unless self.skip?
      end
    end

    def skip?
      @skip
    end

    def to_s
      @name || "anonymous"
    end
  end
end