require "xccache/spm"

module XCCache
  class Command
    class Remote < Command
      class Pull < Remote
        self.summary = "Pulling cache to local"

        def run
          storage.pull
        end
      end
    end
  end
end
