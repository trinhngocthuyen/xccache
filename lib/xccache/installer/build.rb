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
          targets: @target,
          sdk: @sdk,
          out_dir: config.spm_binaries_frameworks_dir,
        )
      end
    end
  end
end
