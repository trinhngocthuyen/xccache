require "xccache/installer"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          ["--sdk=iphonesimulator", "SDKs to build (comma separated)"],
          ["--integrate/no-integrate", "Whether to integrate after building target"],
        ].concat(super)
      end
      self.arguments = [
        CLAide::Argument.new("TARGET", false, true),
      ]

      def initialize(argv)
        super
        @sdk = argv.option("sdk")
        @should_integrate = argv.flag?("integrate", true)
        @targets = argv.arguments!
      end

      def run
        installer = Installer::Build.new(targets: @targets, sdk: @sdk)
        installer.install!
        # Reuse umbrella_pkg from previous installers
        Installer::Use.new(umbrella_pkg: installer.umbrella_pkg).install! if @should_integrate
      end
    end
  end
end
