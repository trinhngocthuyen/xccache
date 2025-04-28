require "xccache/spm"

module XCCache
  class Installer
    class Build < Installer
      def initialize(options = {})
        super
        @targets = options[:targets]
        @sdk = options[:sdk]
        @recursive = options[:recursive]
      end

      def install!
        perform_install do
          umbrella_pkg.build(
            targets: @targets,
            sdk: @sdk,
            out_dir: config.spm_binaries_frameworks_dir,
            checksum: true,
            recursive: @recursive,
          )
        end
      end
    end
  end
end
