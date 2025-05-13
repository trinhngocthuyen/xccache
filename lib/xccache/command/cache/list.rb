module XCCache
  class Command
    class Cache < Command
      class List < Cache
        self.summary = "Listing cache"

        def run
          target_paths = config.spm_cache_dir.glob("*")
          target_paths.each do |target_path|
            next if (paths = target_path.glob("*")).empty?
            descs = paths.map { |p| "  #{p.basename.to_s.green}" }
            UI.info <<~DESC
              #{target_path.basename.to_s.cyan}:
              #{descs.join('\n')}
            DESC
          end
        end
      end
    end
  end
end
