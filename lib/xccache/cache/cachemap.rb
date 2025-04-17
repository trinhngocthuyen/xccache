require "xccache/core"

module XCCache
  module Cache
    class Cachemap < JSONRepresentable
      def deps_data
        raw["deps"] ||= {}
      end

      def cache_data
        raw["cache"] ||= { "hit" => [], "missed" => {} }
      end

      def targets_data
        raw["targets"] ||= {}
      end

      def sync!(lockfile, depmap, pkg_descs_by_name)
        targets = lockfile.product_dependencies.flat_map { |p| depmap[p] || [p] }.uniq
        pkg_descs = pkg_descs_by_name.values.flatten.uniq
        binary_target_names = pkg_descs.flat_map(&:binary_targets).map(&:full_name)

        targets.difference(binary_target_names).each do |d|
          slug, name = d.split("/")
          pkg_desc = pkg_descs_by_name[slug]
          bpath = binary_path(name)
          bpath_with_checksum = binary_path(name, checksum: pkg_desc.checksum)
          # If checksum matches, create symlink from `A-abc123.xcframework` -> `A.framework`
          # Otherwise, remove symlink `A.xcframework`
          if bpath_with_checksum.exist?
            bpath_with_checksum.symlink_to(bpath)
          elsif bpath.symlink?
            bpath.rmtree
          end
        end

        # Hit/missed targets
        hit, missed = [], {}
        targets.each do |d|
          hit << d if !ignore?(d) && binary_exist?(d)
          missed[d] = "no binary" unless binary_exist?(d)
          missed[d] = "ignored" if ignore?(d)
        end

        hit_products, missed_products = [], {}
        lockfile.product_dependencies.each do |product|
          deps = depmap[product] || [product]
          missing = deps.intersection(missed.keys)
          hit_products << product if missing.empty?
          missed_products[product] = missing.map { |d| "#{d} (#{missed[d]})" }.join(", ") unless missing.empty?
        end

        lockfile.product_dependencies_by_targets.each do |target_name, products|
          targets_data["#{target_name}.xccache"] = products.flat_map do |product|
            next product unless hit_products.include?(product)
            depmap[product].map { |x| "#{x}.binary" }
          end.uniq
        end

        raw["deps"] = depmap
        raw["cache"] = {
          "hit" => hit,
          "missed" => missed,
          "hit_products" => hit_products,
          "missed_products" => missed_products,
        }
        print_stats
        save
      end

      def hit?(name)
        cache_data["hit"].include?(name) && !ignore?(name)
      end

      def missed_targets
        cache_data
          .fetch("missed_products", {}).keys
          .flat_map { |p| deps_data[p] }.uniq
          .reject { |x| hit?(x) || ignore?(x) }
          .map { |x| x.split("/").last }
      end

      private

      def binary_path(name, checksum: nil)
        suffix = checksum.nil? ? "" : "-#{checksum}"
        p = Config.instance.spm_binaries_frameworks_dir / File.basename(name, ".binary")
        p / "#{p.basename}#{suffix}.xcframework"
      end

      def binary_exist?(name)
        binary_path(name).exist?
      end

      def ignore?(name)
        Config.instance.ignore?(name)
      end

      def print_stats
        hit_products, missed_products = cache_data["hit_products"], cache_data["missed_products"]
        UI.message <<~DESC
          -------------------------------------------------------------------
          Cache stats
            • Hit (#{hit_products.count}): #{hit_products.to_s.green.dark}
            • Missed (#{missed_products.count}):\n#{JSON.pretty_generate(missed_products).yellow.dark}
          -------------------------------------------------------------------
        DESC
      end
    end
  end
end
