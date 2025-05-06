require "xccache/installer"
require_relative "base"

module XCCache
  class Command
    class Rollback < Command
      self.summary = "Roll back prebuilt cache for packages"

      def run
        Installer::Rollback.new.install!
      end
    end
  end
end
