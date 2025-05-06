require "xccache/installer"

module XCCache
  class Command
    class Options
      SDK = ["--sdk=foo,bar", "SDKs (iphonesimulator, iphoneos, etc.)"].freeze
      SKIP_RESOLVING_DEPENDENCIES = [
        "--skip-resolving-dependencies", "Skip resolving package dependencies",
      ].freeze

      def self.installer_options
        [SDK, SKIP_RESOLVING_DEPENDENCIES]
      end
    end
  end
end
