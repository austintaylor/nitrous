require 'stringio'

module Nitrous
  class HttpIO
    
    def initialize
      @string = String.new
    end
    
    def is_a?(klass)
      klass == IO ? true : super(klass);
    end
  
    def size
      0
    end
  
    def read(len=nil)
      sleep 1 while @string.empty? && !@closed
      return nil if @closed
      string = @string.dup
      @string = ""
      string
    end
    
    def write(string)
      @string << string
    end
    
    def close
      @closed = true
    end
  end
end