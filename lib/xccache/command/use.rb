require "xccache/installer"

module XCCache
  class Command
    class Use < Command
      self.summary = "Use prebuilt cache for packages"
      def self.options
        [
          ["--skip-resolving-dependencies", "Skip resolving package dependencies"],
        ].concat(super)
      end

      def run
        Installer::Use.new(**@install_options).install!
      end
    end
  end
end
