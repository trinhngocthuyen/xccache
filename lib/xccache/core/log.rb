require "xccache/core/config"
require "colored2"

module XCCache
  module UI
    class << self
      include Config::Mixin

      def message(message)
        puts message if config.verbose?
      end

      def info(message)
        puts message
      end

      def error(message)
        puts "[ERROR] #{message}".red
      end
    end
  end
end
