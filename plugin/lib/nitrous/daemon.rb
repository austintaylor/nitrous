require 'webrick'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'http_io')
FileUtils.cd(ARGV[0])
ENV["RAILS_ENV"] = "test"
require "config/environment"

module RailsEnv
  def self.exit_blocks
    @exit_blocks ||= []
  end
end
module Kernel
  def at_exit(&block)
    RailsEnv.exit_blocks << block
  end
end

server = WEBrick::HTTPServer.new(:Port => 4034)
server.mount_proc("/run_test") do |req, res|
  # if pid = fork
  #   Process.wait(pid)
  # else
    # $stdout = Nitrous::HttpIO.new
    # res.body = $stdout
    io = Nitrous::HttpIO.new
    res.body = io
    io.write 'hello'
    # load req.query['file']
    # RailsEnv.exit_blocks.each(&:call)
    io.close
    # $stdout.close
  # end
end
server.start