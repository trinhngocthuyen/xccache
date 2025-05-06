require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          *Options.installer_options,
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
        @recursive = argv.flag?("recursive", false)
      end

      def run
        installer = Installer::Build.new(targets: @targets, recursive: @recursive, **@install_options)
        installer.install!
        # Reuse umbrella_pkg from previous installers
        Installer::Use.new(umbrella_pkg: installer.umbrella_pkg, **@install_options).install! if @should_integrate
      end
    end
  end
end
