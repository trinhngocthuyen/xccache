require "xccache/spm"

module XCCache
  class Command
    class Pkg < Command
      class Build < Pkg
        self.summary = "Build a Swift package into an xcframework"
        def self.options
          [
            Options::SDK,
            ["--config=foo", "Configuration (debug, release)"],
            ["--out=foo", "Output directory for the xcframework"],
            ["--checksum/no-checksum", "Whether to include checksum to the binary name"],
          ].concat(super)
        end
        self.arguments = [
          CLAide::Argument.new("TARGET", false, true),
        ]

        def initialize(argv)
          super
          @targets = argv.arguments!
          @config = argv.option("config")
          @out_dir = argv.option("out")
          @include_checksum = argv.flag?("checksum")
        end

        def run
          pkg = SPM::Package.new
          pkg.build(
            targets: @targets,
            sdks: @sdks,
            config: @config,
            out_dir: @out_dir,
            checksum: @include_checksum,
            skip_resolve: @skip_resolving_dependencies,
          )
        end
      end
    end
  end
end
