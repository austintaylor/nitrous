require 'curses'

class ProgressBarAwareStandardOut
  def initialize(stdout, progress_bar)
    @stdout, @progress_bar = stdout, progress_bar
  end
  
  def write(object)
    @progress_bar.delete_bar
    @stdout.write(object)
    @progress_bar.redraw_bar
  end
  
  def puts(*args)
    args.each do |arg|
      write("#{arg}\n")
    end
  end
  
  def direct_write(object)
    @stdout.write(object)
  end
end

module Kernel
  def puts(*args)
    $stdout.puts(*args)
  end
end

class ProgressBar
  RED   = 101
  GREEN = 102
  
  attr_accessor :color
  
  def initialize(steps)
    @total_steps = steps
    @step = 0
    @color = GREEN
    Curses.init_screen
    @dimensions = [Curses.stdscr.maxx, Curses.stdscr.maxy]
    Curses.close_screen
    puts ""
    $stdout = ProgressBarAwareStandardOut.new($stdout, self)
  end

  def step
    @step += 1
    draw
  end
  
  def draw_bar(color, width)
    $stdout.direct_write("\e[#{color}m#{' '*width}\e[0m\n")
  end
  
  def delete_bar
    $stdout.direct_write("\e[1F\e[0K")
  end

  def draw
    delete_bar
    redraw_bar
  end

  def redraw_bar
    draw_bar(@color, (@dimensions[0].to_f/@total_steps)*@step)
    STDOUT.flush
  end
end

# bar = ProgressBar.new(20)
# 
# 20.times do
#   puts "here"
#   bar.step
#   sleep 0.2
# end
