require "xccache/core/config"
require "colored2"

module XCCache
  module UI
    @indent = 0

    class << self
      include Config::Mixin
      attr_accessor :indent

      def section(title)
        UI.puts(title)
        self.indent += 2
        yield if block_given?
        self.indent -= 2
      end

      def message(message)
        UI.puts(message) if config.verbose?
      end

      def info(message)
        UI.puts(message)
      end

      def error(message)
        UI.puts("[ERROR] #{message}".red)
      end

      def puts(message)
        $stdout.puts("#{' ' * self.indent}#{message}")
      end
    end
  end
end
