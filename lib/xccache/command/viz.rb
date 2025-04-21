require "xccache/installer"

module XCCache
  class Command
    class Viz < Command
      self.summary = "Visualize dependencies"
      def self.options
        [
          ["--out=foo", "Output directory"],
        ].concat(super)
      end

      def initialize(argv)
        super
        @out_dir = argv.option("out")
      end

      def run
        Installer::Viz.new(out_dir: @out_dir).install!
      end
    end
  end
end
