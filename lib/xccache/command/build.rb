require "xccache/installer"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          ["--target=foo", "Targets to build"],
          ["--sdk=iphonesimulator", "SDKs to build (comma separated)"],
        ].concat(super)
      end

      def initialize(argv)
        super
        @target = argv.option("target")
        @sdk = argv.option("sdk")
        @should_use = argv.flag?("use")
      end

      def run
        Installer::Build.new(target: @target, sdk: @sdk).install!
        Installer::Use.new.install! if @should_use
      end
    end
  end
end
