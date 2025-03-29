require "xccache/spm/package"

module XCCache
  class Command
    class Pkg < Command
      class Build < Pkg
        self.summary = "Build a Swift package into an xcframework"
        def self.options
          [
            ["--target=foo", "Target to build"],
            ["--sdk=foo,bar", "Sdk (iphonesimulator, iphoneos, etc.)"],
            ["--config=foo", "Configuration (debug, release)"],
            ["--out=foo", "Output directory for the xcframework"],
          ].concat(super)
        end

        def initialize(argv)
          super
          @target = argv.option("target")
          @sdk = argv.option("sdk")
          @config = argv.option("config")
          @out_dir = argv.option("out")
        end

        def run
          pkg = SPM::Package.new
          pkg.build(
            target: @target,
            sdk: @sdk,
            config: @config,
            out_dir: @out_dir,
          )
        end
      end
    end
  end
end
