unless defined? RailsEnv
  require 'drb'
  
  module Kernel
    def at_exit(&block)
      RailsEnv.exit_blocks << block
    end
  end
  
  DRbObject.send(:undef_method, :puts)
  
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
      
      def exit_blocks
        @exit_blocks ||= []
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
      if fork
        Process.wait
      else
        load filename
        self.class.exit_blocks.each(&:call)
      end
    rescue Exception
      $stdout.print($!)
    end
  
    def console(_in, out)
      require "commands/console"
      $stdin, $stdout = _in, out
    end
  end

  if __FILE__ == $0
    RailsEnv.create_server("../../lawndarts")
  else
    RailsEnv.join
  end
end