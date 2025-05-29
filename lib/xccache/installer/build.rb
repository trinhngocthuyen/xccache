require "xccache/spm"

module XCCache
  class Installer
    class Build < Installer
      def initialize(options = {})
        super
        @targets = options[:targets]
      end

      def install!
        perform_install do
          build(
            targets: @targets,
            out_dir: config.spm_cache_dir,
            symlinks_dir: config.spm_binaries_dir,
            checksum: true,
            **@build_options,
          )
          proxy_pkg.gen_proxy # Regenerate proxy to apply new cache after build
        end
      end
    end
  end
end
