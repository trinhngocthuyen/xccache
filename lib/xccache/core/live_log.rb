require "monitor"
require "tty-cursor"
require "tty-screen"

module XCCache
  class LiveLog
    include UI::Mixin
    CURSOR_LOCK = Monitor.new

    attr_reader :output, :max_lines, :lines, :cursor, :tee

    def initialize(**options)
      @output = options[:output] || $stdout
      @max_lines = options[:max_lines] || 5
      @n_sticky = 0
      @lines = []
      @cursor = TTY::Cursor
      @screen = TTY::Screen
      @tee = options[:tee]
    end

    def clear
      commit do
        output.print(cursor.clear_lines(lines.count + @n_sticky))
        @lines = []
        @n_sticky = 0
      end
    end

    def puts(line, sticky: false)
      commit do
        output.print(cursor.clear_lines(lines.count + 1))
        if sticky
          @n_sticky += 1
          output.puts(truncated(line))
        else
          lines.shift if lines.count >= max_lines
          lines << truncated(line)
        end
        output.puts(lines) # print non-sticky content
      end
      File.open(tee, "a") { |f| f << "#{line}\n" } if tee
    end

    def capture(header)
      header_start = header.magenta.bold
      header_success = "#{header} ✔".green.bold
      header_error = "#{header} ✖".red.bold
      puts(header_start, sticky: true)
      yield if block_given?
      clear
      update_header(header_success)
    rescue StandardError => e
      update_header(header_error)
      raise e
    end

    private

    def update_header(header)
      commit do
        n = lines.count + @n_sticky
        output.print(cursor.up(n) + header + cursor.column(0) + cursor.down(n))
      end
    end

    def commit
      CURSOR_LOCK.synchronize do
        yield
        output.flush
      end
    end

    def truncated(msg)
      msg.length > @screen.width ? "#{msg[...@screen.width - 3]}..." : msg
    end

    def ui_cls
      self
    end
  end
end
