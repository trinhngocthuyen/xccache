require "claide"
require "xccache/core/config"

module XCCache
  class Command < CLAide::Command
    include Config::Mixin
    Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

    self.abstract_command = true
    self.default_subcommand = "use"
    self.summary = "xccache - a build caching tool"

    def initialize(argv)
      super
      config.verbose = verbose unless verbose.nil?
      @skip_resolving_dependencies = argv.flag?("skip-resolving-dependencies")
      @install_options = { :skip_resolving_dependencies => @skip_resolving_dependencies }
    end
  end
end
