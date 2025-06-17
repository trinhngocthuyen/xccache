require "xccache/core/config"
require "colored2"

module XCCache
  module UI
    @indent = 0

    module Mixin
      include Config::Mixin
      attr_accessor :indent

      def section(title, timing: false)
        start = Time.new if timing
        ui_cls.puts(title)
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
          ui_cls.puts("-> Finished: #{title.dark} (#{duration})")
        end
        res
      end

      def message(message)
        ui_cls.puts(message) if config.verbose?
      end

      def info(message)
        ui_cls.puts(message)
      end

      def warn(message)
        ui_cls.puts(message.yellow)
      end

      def error(message)
        ui_cls.puts("[ERROR] #{message}".red)
      end

      def error!(message)
        error(message)
        raise GeneralError, message
      end

      def puts(message)
        $stdout.puts("#{' ' * self.indent}#{message}")
      end

      private

      def ui_cls
        UI
      end
    end

    class << self
      include Mixin
    end
  end
end
