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
        umbrella_pkg.build(
          target: @target || infer_targets,
          sdk: @sdk,
          out_dir: config.spm_binaries_frameworks_dir,
        )
        update_cachemap
      end

      private

      def infer_targets
        # FIXME: Hardcoded for POC
        ["SwiftyBeaver", "Moya", "Alamofire"]
      end

      def update_cachemap
        # TODO: Implement this
      end
    end
  end
end
