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
        sync_lockfile
        umbrella_pkg.prepare
        umbrella_pkg.resolve_recursive_dependencies
        umbrella_pkg.gen_cachemap(lockfile)
        umbrella_pkg.build(
          target: @target || infer_targets,
          sdk: @sdk,
          out_dir: config.spm_binaries_frameworks_dir,
        )
      end

      private

      def infer_targets
        # FIXME: Hardcoded for POC
        ["SwiftyBeaver"]
      end
    end
  end
end
