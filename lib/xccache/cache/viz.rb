require "xccache/spm/pkg"

module XCCache
  module Cache
    class Visualizer
      include PkgMixin

      def run
        umbrella_pkg.prepare
        # TODO: Resolve recursive dependencies
      end
    end
  end
end
