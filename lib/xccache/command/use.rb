require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Use < Command
      self.summary = "Use prebuilt cache for packages"
      def self.options
        [
          *Options.installer_options,
        ].concat(super)
      end

      def run
        Installer::Use.new(**@install_options).install!
      end
    end
  end
end
