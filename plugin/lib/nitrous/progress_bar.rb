require 'curses'

module Kernel
  def puts(*args)
    $stdout.puts(*args)
  end
end

module Nitrous
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

  class ProgressBar
    RED   = 101
    GREEN = 102

    attr_accessor :color, :text

    def initialize(steps)
      @total_steps = steps
      @step = 0
      @color = GREEN
      Curses.init_screen
      @dimensions = [Curses.stdscr.maxx, Curses.stdscr.maxy]
      Curses.close_screen
      $stdout.puts ""
      $stdout = ProgressBarAwareStandardOut.new($stdout, self)
      @text = ""
    end

    def step
      @step += 1
      draw
    end

    def draw_bar(color, width)
      content = @text[0..[width, @text.length].min] + " " * [width - @text.length, 0].max
      $stdout.direct_write("\e[#{color}m#{content}\e[0m")
      $stdout.direct_write(@text[(width + 1)..-1]) if @text.length > width
      $stdout.direct_write("\n")
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
end