module XCCache
  class Command
    class Cache < Command
      class Clean < Cache
        self.summary = "Cleaning/purging cache"
        self.arguments = [CLAide::Argument.new("TARGET", false, true)]
        def self.options
          [
            ["--all", "Whether to remove all cache (default: false)"],
            ["--dry", "Dry run - don't remove cache, just show what shall be removed (default: false)"],
          ].concat(super)
        end

        def initialize(argv)
          super
          @all = argv.flag?("all")
          @dry = argv.flag?("dry")
          @targets = argv.arguments!
        end

        def run
          to_remove = @targets.flat_map { |t| config.spm_cache_dir.glob("#{t}/*") }
          to_remove = config.spm_cache_dir.glob("*/*") if @all
          to_remove.each do |p|
            UI.info("Removing #{p.basename.to_s.yellow}")
            p.rmtree unless @dry
          end
        end
      end
    end
  end
end
