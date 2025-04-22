require "xccache/core"

module XCCache
  module Cache
    class Cachemap < JSONRepresentable
      def deps_data
        raw["deps"] ||= {}
      end

      def depgraph_data
        raw["depgraph"] ||= {}
      end

      def cache_data
        raw["cache"] ||= { "hit" => [], "missed" => {} }
      end

      def targets_data
        raw["targets"] ||= {}
      end

      def sync!(lockfile, pkg_group)
        @lockfile, @pkg_group = lockfile, pkg_group
        gen_cache_data
        gen_depgraph_data
        print_stats
        save
      end

      def result_type(name)
        return :ignored if ignore?(name)
        return :hit if hit?(name)
        :missed
      end

      def hit?(name)
        cache_data["hit"].include?(name) && !ignore?(name)
      end

      def hit_product?(name)
        cache_data["hit_products"].include?(name) && !ignore?(name)
      end

      def missed_targets
        missed_products = cache_data.fetch("missed_products", {}).keys
        @pkg_group
          .dependency_targets_of_products(missed_products)
          .reject { |x| hit?(x.full_name) || ignore?(x.full_name) }
          .map(&:name)
      end

      private

      def gen_cache_data
        binary_target_names = @pkg_group.binary_targets.map(&:full_name)
        targets = @pkg_group.dependency_targets_of_products(@lockfile.product_dependencies).map(&:full_name)
        targets.difference(binary_target_names).each do |d|
          bpath = binary_path(File.basename(d))
          bpath_with_checksum = binary_path(File.basename(d), checksum: @pkg_group.desc_of(d).checksum)
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
        @lockfile.product_dependencies.each do |product|
          missing = @pkg_group.dependency_targets_of_products(product).map(&:full_name).intersection(missed.keys)
          hit_products << product if missing.empty?
          missed_products[product] = missing.map { |d| "#{d} (#{missed[d]})" }.join(", ") unless missing.empty?
        end

        @lockfile.product_dependencies_by_targets.each do |target_name, products|
          targets_data["#{target_name}.xccache"] = products.flat_map do |product|
            next product unless hit_products.include?(product)
            @pkg_group.dependency_targets_of_products(product).map { |x| "#{x.full_name}.binary" }
          end.uniq
        end

        raw["cache"] = {
          "hit" => hit,
          "missed" => missed,
          "hit_products" => hit_products,
          "missed_products" => missed_products,
        }
      end

      def gen_depgraph_data
        nodes, edges, parents = [], [], {}
        to_visit = @lockfile.product_dependencies_by_targets.flat_map do |target_name, deps|
          nodes << { :id => target_name, :label => target_name, :agg => true }
          targets = @pkg_group.targets_of_products(deps)
          targets.each { |t| edges << { :source => target_name, :target => t.full_name } }
          targets
        end.uniq

        until to_visit.empty?
          target = to_visit.pop
          nodes << { :id => target.full_name, :label => target.name }
          target.direct_dependency_targets.each do |t|
            parents[t.full_name] ||= []
            parents[t.full_name] << target.full_name
            edges << { :source => target.full_name, :target => t.full_name }
            to_visit << t unless to_visit.include?(t)
          end
        end
        nodes.uniq!

        nodes_by_name = nodes.to_h { |h| [h[:id], h] }
        nodes.reject { |h| h[:agg] }.each do |h|
          h[:cache] = result_type(h[:id]) unless h.key?(:cache)
          next if h[:cache] == :hit || !parents.key?(h[:id])
          parents[h[:id]].each do |p|
            nodes_by_name[p][:cache] = :missed
          end
        end
        raw["depgraph"] = { :nodes => nodes, :edges => edges }
      end

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
