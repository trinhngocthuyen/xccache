require "xccache/installer"

module XCCache
  class Command
    class Init < Command
      self.summary = "Initialize xccache setup"

      def run
        Installer.new.sync_lockfile
      end
    end
  end
end
