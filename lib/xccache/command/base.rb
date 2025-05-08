require "xccache/installer"

module XCCache
  class Command
    class Options
      SDK = ["--sdk=foo,bar", "SDKs (iphonesimulator, iphoneos, etc.)"].freeze
      CONFIG = ["--config=foo", "Configuration (debug, release)"].freeze
      SKIP_RESOLVING_DEPENDENCIES = [
        "--skip-resolving-dependencies", "Skip resolving package dependencies",
      ].freeze
      MERGE_SLICES = [
        "--merge-slices/--no-merge-slices",
        "Whether to merge with existing slices/sdks in the xcframework (default: true)",
      ].freeze

      def self.install_options
        [SDK, SKIP_RESOLVING_DEPENDENCIES]
      end

      def self.build_options
        install_options + [CONFIG, MERGE_SLICES]
      end
    end
  end
end
