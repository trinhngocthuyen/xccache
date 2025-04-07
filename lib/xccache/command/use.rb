require "xccache/installer"

module XCCache
  class Command
    class Use < Command
      self.summary = "Use prebuilt cache for packages"

      def run
        Installer::Use.new.install!
      end
    end
  end
end
