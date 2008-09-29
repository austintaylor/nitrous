if !Array.instance_methods.include?('sum')
  class Array
    def sum
      inject(0) do |sum, each|
        block_given? ? sum + yield(each) : sum + each
      end
    end
  end
end

class Symbol
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class Exception
  def format
    to_s + "\n" + backtrace.join("\n")
  end
end

class Hash
  def to_s
    map {|k,v| "#{k}: #{v}"}.join("\r\n")
  end
end