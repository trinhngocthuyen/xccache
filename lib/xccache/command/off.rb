require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Off < Command
      self.summary = "Force-switch to source mode for specific targets"
      self.arguments = [
        CLAide::Argument.new("TARGET", false, true),
      ]

      def initialize(argv)
        super
        @targets = argv.arguments!
      end

      def run
        return if @targets.empty?

        UI.info("Will force-use source mode for targets: #{@targets}")
        @targets.each { |t| config.ignore_list << "*/#{t}" }
        Installer::Use.new(ctx: self).install!
      end
    end
  end
end
