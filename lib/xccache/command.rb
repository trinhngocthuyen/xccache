require "claide"

module XCCache
  class Command < CLAide::Command
    require "xccache/command/pkg"

    self.abstract_command = true
    self.summary = "xccache - a build caching tool"
  end
end
