require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          *Options.build_options,
          ["--integrate/no-integrate", "Whether to integrate after building target (default: true)"],
          ["--recursive", "Whether to build their recursive targets if cache-missed (default: false)"],
        ].concat(super)
      end
      self.arguments = [
        CLAide::Argument.new("TARGET", false, true),
      ]

      def initialize(argv)
        super
        @targets = argv.arguments!
        @should_integrate = argv.flag?("integrate", true)
      end

      def run
        installer = Installer::Build.new(
          ctx: self,
          targets: @targets,
        )
        installer.install!

        # Reuse umbrella_pkg from previous installers
        return unless @should_integrate
        Installer::Use.new(
          ctx: self,
          umbrella_pkg: installer.umbrella_pkg,
        ).install!
      end
    end
  end
end
