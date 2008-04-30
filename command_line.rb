require 'rubygems'
require 'activesupport'
class CommandLineUtility
  class << self
    def inherited(klass)
      klass.descriptions = descriptions.dup
    end
    
    def run
      return unless name.underscore == $0.split("/").last
      instance = self.new
      if ARGV.empty?
        instance.default
      else
        instance.send(ARGV.first, *ARGV[1..-1])
      end
    end
    
    def descriptions=(descriptions)
      @descriptions = descriptions
    end
  
    def descriptions
      @descriptions ||= HashWithIndifferentAccess.new
    end
  
    def describe(command, description)
      descriptions[command] = description
    end
  
    def description_for(command)
      descriptions[command]
    end
  
    def commands
      self.public_instance_methods.sort - Object.public_instance_methods - ["default"]
    end
  end
  
  describe :help, "Print this help"
  def help
    puts "usage: #{self.class.name.underscore} [COMMAND [ARGS]]"
    puts ""
    puts "Commands:"
    stuff = self.class.commands.map do |command|
      description = self.class.description_for(command)
      description ? "  #{command} (#{description})" : "  #{command}"
    end
    puts stuff
  end
  
  alias_method :default, :help
end