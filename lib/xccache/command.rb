require "claide"
require "xccache/core/config"

module XCCache
  class Command < CLAide::Command
    include Config::Mixin
    Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

    self.abstract_command = true
    self.summary = "xccache - a build caching tool"

    def initialize(argv)
      super
      config.verbose = verbose unless verbose.nil?
    end
  end
end
