require "xccache/spm"

module XCCache
  module Cache
    class Visualizer
      include PkgMixin

      def run
        umbrella_pkg.prepare
        # TODO: Render graph
      end
    end
  end
end
