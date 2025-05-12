require "xccache/spm"

module XCCache
  class Command
    class Remote < Command
      class Push < Remote
        self.summary = "Pushing cache to remote"

        def run
          storage.push
        end
      end
    end
  end
end
