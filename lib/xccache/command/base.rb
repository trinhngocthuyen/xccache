require "xccache/installer"

module XCCache
  class Command
    class Options
      SDK = ["--sdk=foo,bar", "SDKs (iphonesimulator, iphoneos, etc.)"].freeze
      CONFIG = ["--config=foo", "Configuration (debug, release) (default: debug)"].freeze
      SKIP_RESOLVING_DEPENDENCIES = [
        "--skip-resolving-dependencies", "Skip resolving package dependencies",
      ].freeze
      MERGE_SLICES = [
        "--merge-slices/--no-merge-slices",
        "Whether to merge with existing slices/sdks in the xcframework (default: true)",
      ].freeze
      LIBRARY_EVOLUTION = [
        "--library-evolution/--no-library-evolution",
        "Whether to enable library evolution (build for distribution) (default: false)",
      ].freeze

      def self.install_options
        [SDK, CONFIG, SKIP_RESOLVING_DEPENDENCIES]
      end

      def self.build_options
        install_options + [MERGE_SLICES, LIBRARY_EVOLUTION]
      end
    end
  end
end
