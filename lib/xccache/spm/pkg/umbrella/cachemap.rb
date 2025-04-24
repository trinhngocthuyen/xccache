module XCCache
  module SPM
    class Package
      module UmbrellaCachemapMixin
        def sync_cachemap
          UI.section("Syncing cachemap")
          nodes, edges, parents = xccache_desc.traverse
          cache_data = gen_cache_data(nodes, parents)
          targets_data = xccache_desc.targets.to_h do |agg_target|
            deps = agg_target.direct_dependencies.flat_map do |d|
              # If any associated targets is missed -> use original product form
              # Otherwise, replace with recursive targets' binaries
              if d.flatten_as_targets.all? { |t| cache_data[t] == :hit }
                d.recursive_targets.map { |t| "#{t.full_name}.binary" }
              else
                d.full_name
              end
            end
            [agg_target.name, deps]
          end

          config.cachemap.raw = {
            "targets" => targets_data,
            "cache" => cache_data.transform_keys(&:full_name),
            "depgraph" => {
              "nodes" => nodes.map { |x| target_to_cytoscape_node(x, cache_data) },
              "edges" => edges.map { |x, y| { :source => x.full_name, :target => y.full_name } },
            },
          }
          config.cachemap.save
          config.cachemap.print_stats
        end

        private

        def gen_cache_data(nodes, parents)
          result = {}
          nodes.reject(&:xccache?).each do |node|
            next if result.key?(node)
            result[node] = :missed
            result[node] = :hit if verify_binary?(node)
            result[node] = :ignored if config.ignore?(node.full_name)
            # Mark dependants as missed
            if %i[missed ignored].include?(result[node]) && parents.key?(node)
              parents[node].reject(&:xccache?).each { |p| result[p] = :missed if result[p] != :ignored }
            end
          end
          result
        end

        def verify_binary?(target)
          return true if target.binary?

          bpath = binary_path(target.name)
          bpath_with_checksum = binary_path(target.name, checksum: target.root.checksum)
          # If checksum matches, create symlink from `A-abc123.xcframework` -> `A.framework`
          # Otherwise, remove symlink `A.xcframework`
          if bpath_with_checksum.exist?
            bpath_with_checksum.symlink_to(bpath)
          elsif bpath.exist?
            bpath.rmtree
          end
          bpath_with_checksum.exist?
        end

        def binary_path(name, checksum: nil)
          suffix = checksum.nil? ? "" : "-#{checksum}"
          p = config.spm_binaries_frameworks_dir / File.basename(name, ".binary")
          p / "#{p.basename}#{suffix}.xcframework"
        end

        def target_to_cytoscape_node(x, cache_data)
          h = { :id => x.full_name, :cache => cache_data[x] }
          h[:type] = "agg" if x.name.end_with?(".xccache")
          h[:checksum] = x.root.checksum
          h[:binary] = binary_path(x.name) if cache_data[x] == :hit
          h
        end
      end
    end
  end
end
