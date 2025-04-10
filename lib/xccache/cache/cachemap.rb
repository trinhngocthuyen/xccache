require "xccache/core/json"

module XCCache
  module Cache
    class Cachemap < JSONRepresentable
      def deps_data
        raw["_deps_"]
      end

      def cache_data
        raw.reject { |k, _| k == "_deps_" }
      end

      def sync!(lockfile, projects, depmap)
        # FIXME: Handle upstream/downstream cache invalidation
        raw["_deps_"] = depmap
        projects.each do |project|
          target_deps = lockfile[project.display_name]["dependencies"].to_h do |target_name, products|
            deps = products.flat_map { |p| depmap[p] || [p] }.map { |d| hit?(d) ? "#{d}.binary" : d }
            [target_name, deps]
          end
          raw[project.display_name] = target_deps
        end
        save
      end

      def hit?(name)
        binary_path(name).exist?
      end

      def miss?(name)
        !hit?(name)
      end

      def missed
        all_items = cache_data.values.flat_map { |h| h.values.flatten }
        all_items.select { |x| miss?(x) }.map { |x| x.split("/")[-1] }
      end

      def binary_path(name)
        basename = File.basename(name, ".binary")
        XCCache::Config.instance.spm_binaries_frameworks_dir / "#{basename}.xcframework"
      end
    end
  end
end
