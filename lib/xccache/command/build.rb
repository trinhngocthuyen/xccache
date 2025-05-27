require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Build < Command
      self.summary = "Build packages to xcframeworks"
      def self.options
        [
          *Options.build_options,
          ["--recursive", "Whether to build their recursive targets if cache-missed (default: false)"],
        ].concat(super)
      end
      self.arguments = [
        CLAide::Argument.new("TARGET", false, true),
      ]

      def initialize(argv)
        super
        @targets = argv.arguments!
      end

      def run
        Installer::Build.new(ctx: self, targets: @targets).install!
      end
    end
  end
end
