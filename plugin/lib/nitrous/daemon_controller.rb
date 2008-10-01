require 'rubygems'
require 'daemons'

RAILS_ROOT = ARGV.last
options = {
    :ARGV => [RAILS_ROOT]
    :app_name => 'nitrous_server',
    :dir_mode => :normal,
    :dir => File.join(RAILS_ROOT, 'tmp/pids/')
}
Daemons.run(File.join(File.dirname(__FILE__), 'daemon.rb'), options)