require "xccache/core/config"
require "colored2"

module XCCache
  module UI
    @indent = 0

    class << self
      include Config::Mixin
      attr_accessor :indent

      def section(title, timing: false)
        start = Time.new if timing
        UI.puts(title)
        self.indent += 2
        res = yield if block_given?
        self.indent -= 2
        if timing
          duration = (Time.new - start).to_i
          duration = if duration < 60 then "#{duration}s"
                     elsif duration < 60 * 60 then "#{duration / 60}m"
                     else
                       "#{duration / 3600}h"
                     end
          UI.puts("-> Finished: #{title.dark} (#{duration})")
        end
        res
      end

      def message(message)
        UI.puts(message) if config.verbose?
      end

      def info(message)
        UI.puts(message)
      end

      def warn(message)
        UI.puts(message.yellow)
      end

      def error(message)
        UI.puts("[ERROR] #{message}".red)
      end

      def error!(message)
        error(message)
        raise GeneralError, message
      end

      def puts(message)
        $stdout.puts("#{' ' * self.indent}#{message}")
      end
    end
  end
end
