require "claide"
require "xccache/core/config"
require "xccache/swift/sdk"

module XCCache
  class Command < CLAide::Command
    include Config::Mixin
    Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

    self.abstract_command = true
    self.default_subcommand = "use"
    self.summary = "xccache - a build caching tool"

    attr_reader :install_options, :build_options

    def initialize(argv)
      super
      config.verbose = verbose unless verbose.nil?
      config.install_config = argv.option("config", "debug")
      @install_options = {
        :sdks => str_to_sdks(argv.option("sdk")),
        :config => config.install_config,
        :skip_resolving_dependencies => argv.flag?("skip-resolving-dependencies"),
      }
      @build_options = {
        **@install_options,
        :recursive => argv.flag?("recursive"),
        :merge_slices => argv.flag?("merge-slices", true),
        :library_evolution => argv.flag?("library-evolution"),
      }
    end

    def str_to_sdks(str)
      (str || config.default_sdk).split(",").map { |s| Swift::Sdk.new(s) }
    end
  end
end
