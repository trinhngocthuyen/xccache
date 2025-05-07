require "xccache/spm"

module XCCache
  class Installer
    class Build < Installer
      def initialize(options = {})
        super
        @targets = options[:targets]
        @recursive = options[:recursive]
        @merge_slices = options[:merge_slices]
      end

      def install!
        perform_install do
          umbrella_pkg.build(
            targets: @targets,
            sdks: @sdks,
            out_dir: config.spm_binaries_frameworks_dir,
            checksum: true,
            merge_slices: @merge_slices,
            recursive: @recursive,
            skip_resolve: @skip_resolving_dependencies,
          )
        end
      end
    end
  end
end
