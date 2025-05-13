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
          umbrella_pkg.build(
            targets: @targets,
            out_dir: config.spm_cache_dir,
            checksum: true,
            **@build_options,
          )
        end
      end
    end
  end
end
