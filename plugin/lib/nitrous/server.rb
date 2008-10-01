PID_FILE = File.expand_path(File.join(RAILS_ROOT, 'tmp/pids/nitrous_server.pid'))
if File.exists?(PID_FILE) && !`ps ax | grep "\b#{File.read(PID_FILE)}\b"`.empty?
  `ruby #{File.join(File.dirname(__FILE__), 'daemon_controller.rb')} start #{File.expand_path(RAILS_ROOT)}`
end
