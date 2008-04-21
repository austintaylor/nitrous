require 'drb'

class RailsEnv
  class << self
    def join
      DRb.start_service
      ro = DRbObject.new(nil, 'druby://:7777')
      ro.stdout = $stdout
      ro.run_file($0)
      exit
    end

    def create_server(path)
      puts "create_server"
      DRb.start_service("druby://:7777", RailsEnv.new(path))
      DRb.thread.join
    end
  end
  
  def initialize(path)
    require File.join(path, "config/environment")
    puts "ready"
  end
  
  def stdout=(stdout)
    $stdout = stdout
  end
  
  def run(&block)
    yield
  end
  
  def run_file(filename)
    # if fork
    #   Process.wait
    # else
      load filename
    # end
  rescue Exception
    $stdout.print($!)
  end
  
  def console(_in, out)
    require "commands/console"
    $stdin, $stdout = _in, out
  end
end

p [__FILE__, $0]
if __FILE__ == $0
  RailsEnv.create_server("/Users/dotjerky/projects/lawndarts")
else
  RailsEnv.join
end
