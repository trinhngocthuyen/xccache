module XCCache
  module SPM
    class Package
      module UmbrellaCachemapMixin
        def sync_cachemap
          UI.section("Syncing cachemap")
          nodes, edges, parents = xccache_desc.traverse
          cache_data = gen_cache_data(nodes, parents)
          targets_data, deps_data = {}, {}
          xccache_desc.targets.each do |agg_target|
            targets_data[agg_target.name] = agg_target.direct_dependencies.flat_map do |d|
              # If any associated targets is missed -> use original product form
              # Otherwise, replace with recursive targets' binaries
              deps_data[d.full_name] = d.recursive_targets.map(&:full_name)
              if d.recursive_targets.all? { |t| cache_data[t] == :hit }
                "#{d.full_name}.binary"
              else
                d.full_name
              end
            end.uniq.sort_by(&:downcase)
          end

          config.cachemap.raw = {
            "manifest" => {
              "targets" => targets_data,
              "deps" => deps_data,
            },
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
          result = nodes.to_h do |node|
            res = if config.ignore?(node.full_name) then :ignored
                  else
                    verify_binary?(node) ? :hit : :missed
                  end
            [node, res]
          end

          # Propagate cache miss
          to_visit = result.select { |_, v| %i[missed ignore].include?(v) }.keys
          visited = Set.new
          until to_visit.empty?
            node = to_visit.pop
            next if visited.include?(node)
            visited << node
            result[node] = :missed if result[node] == :hit
            to_visit += parents[node] if parents.key?(node)
          end
          result.reject { |k, _| k.name.end_with?(".xccache") }
        end

        def verify_binary?(target)
          return true if target.binary?

          bpath = binary_path(target.name)
          bpath_with_checksum = binary_path(target.name, checksum: target.checksum)
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
          h[:checksum] = x.checksum
          h[:binary] = binary_path(x.name) if cache_data[x] == :hit
          h
        end
      end
    end
  end
end
