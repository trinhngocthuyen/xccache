require "xccache/command/pkg/build"

module XCCache
  class Command
    class Pkg < Command
      self.abstract_command = true
      self.summary = "Working with Swift packages"
    end
  end
end
