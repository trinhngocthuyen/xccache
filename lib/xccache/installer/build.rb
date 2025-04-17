require "xccache/spm"

module XCCache
  class Installer
    class Build < Installer
      def initialize(options = {})
        super
        @target = options[:target]
        @sdk = options[:sdk]
      end

      def install!
        perform_install do
          umbrella_pkg.build(
            targets: @target,
            sdk: @sdk,
            out_dir: config.spm_binaries_frameworks_dir,
            checksum: true,
          )
          # After building targets, update manifest to use binaries
          umbrella_pkg.write_manifest(force: true)
        end
      end
    end
  end
end
