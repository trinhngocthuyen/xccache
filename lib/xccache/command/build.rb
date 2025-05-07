require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          *Options.installer_options,
          Options::MERGE_SLICES,
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
        @recursive = argv.flag?("recursive")
        @merge_slices = argv.flag?("merge-slices", true)
      end

      def run
        installer = Installer::Build.new(
          targets: @targets,
          recursive: @recursive,
          merge_slices: @merge_slices,
          **@install_options,
        )
        installer.install!

        # Reuse umbrella_pkg from previous installers
        return unless @should_integrate
        Installer::Use.new(
          umbrella_pkg: installer.umbrella_pkg,
          **@install_options,
        ).install!
      end
    end
  end
end
