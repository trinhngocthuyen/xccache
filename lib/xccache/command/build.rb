require "xccache/installer"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          ["--target=foo", "Targets to build"],
          ["--sdk=iphonesimulator", "SDKs to build (comma separated)"],
          ["--integrate/no-integrate", "Whether to integrate after building target"],
        ].concat(super)
      end

      def initialize(argv)
        super
        @target = argv.option("target")
        @sdk = argv.option("sdk")
        @should_integrate = argv.flag?("integrate", true)
      end

      def run
        installer = Installer::Build.new(target: @target, sdk: @sdk)
        installer.install!
        # Reuse umbrella_pkg from previous installers
        Installer::Use.new(umbrella_pkg: installer.umbrella_pkg).install! if @should_integrate
      end
    end
  end
end
