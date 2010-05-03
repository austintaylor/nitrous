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
    
    def filename
      parse_location
      @filename
    end
    
    def line
      parse_location
      @line
    end
    
    def skip?
      @skip
    end

    def to_s
      @name || first_line
    end
    
    def first_line
      "[ #{File.readlines(filename)[line].strip} ]"
    end
    
    private
      def parse_location
        return if @filename && @line
        @block.inspect =~ /#<Proc:[^@]+@([^:]+):(\d+)>/
        @filename = $1
        @line = $2.to_i
      end
  end
end