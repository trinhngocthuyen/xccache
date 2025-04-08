require "xccache/installer"

module XCCache
  class Command
    class Viz < Command
      self.summary = "Visualize dependencies"

      def run
        Cache::Visualizer.new.run
      end
    end
  end
end
