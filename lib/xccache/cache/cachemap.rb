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

      def sync!(lockfile, depmap)
        # Hit/missed targets
        hit, missed =
          lockfile
          .product_dependencies
          .flat_map { |p| depmap[p] || [p] }.uniq
          .partition { |d| binary_path(d).exist? && !Config.instance.ignore?(d) }

        hit_products, missed_products = [], {}
        lockfile.product_dependencies.each do |product|
          deps = depmap[product] || [product]
          missing = deps.difference(hit)
          hit_products << product if missing.empty?
          missed_products[product] = "missed targets: #{missing.join(', ')}" unless missing.empty?
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
        unless missed_products.empty?
          UI.message("Cache missed (products):\n#{JSON.pretty_generate(missed_products).yellow.dark}")
        end
        save
      end

      def hit?(name)
        cache_data["hit"].include?(name) && !Config.instance.ignore?(name)
      end

      def miss?(name)
        !hit?(name)
      end

      def missed_targets
        cache_data
          .fetch("missed_products", {}).keys
          .flat_map { |p| deps_data[p] }.uniq
          .reject { |x| hit?(x) }
          .map { |x| x.split("/").last }
      end

      private

      def binary_path(name)
        basename = File.basename(name, ".binary")
        Config.instance.spm_binaries_frameworks_dir / "#{basename}.xcframework"
      end
    end
  end
end
