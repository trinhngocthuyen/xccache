require_relative "base"
require "xccache/command/cache/clean"
require "xccache/command/cache/list"

module XCCache
  class Command
    class Cache < Command
      self.abstract_command = true
      self.summary = "Working with cache (list, clean, etc.)"
    end
  end
end
