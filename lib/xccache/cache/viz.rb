require "xccache/spm"

module XCCache
  module Cache
    class Visualizer
      include PkgMixin

      def run
        umbrella_pkg.prepare(gen_metadata: true)
        # TODO: Resolve recursive dependencies
      end
    end
  end
end
