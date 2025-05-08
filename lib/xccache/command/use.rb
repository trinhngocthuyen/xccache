require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Use < Command
      self.summary = "Use prebuilt cache for packages"
      def self.options
        [
          *Options.install_options,
        ].concat(super)
      end

      def run
        Installer::Use.new(ctx: self).install!
      end
    end
  end
end
