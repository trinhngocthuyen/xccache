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
      set_ansi_mode
      config.verbose = verbose unless verbose.nil?
      config.install_config = argv.option("config", "debug")
      @install_options = {
        :sdks => str_to_sdks(argv.option("sdk")),
        :config => config.install_config,
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

    private

    def set_ansi_mode
      config.ansi = ansi_output?
      return if ansi_output?
      Colored2.disable!
      String.send(:define_method, :colorize) { |s, _| s }
    end
  end
end
