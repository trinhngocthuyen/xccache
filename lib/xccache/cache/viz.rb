require "xccache/spm"

module XCCache
  module Cache
    class Visualizer
      include PkgMixin

      def run
        umbrella_pkg.prepare
        umbrella_pkg.resolve_recursive_dependencies
        # TODO: Render graph
      end
    end
  end
end
