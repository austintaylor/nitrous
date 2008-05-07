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
      @name || first_line
    end
    
    def first_line
      @block.inspect =~ /#<Proc:[^@]+@([^:]+):(\d+)>/
      line = File.readlines($1)[$2.to_i].strip
      "[ #{line} ]"
    end
  end
end