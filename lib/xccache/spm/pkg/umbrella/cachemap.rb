module XCCache
  module SPM
    class Package
      module UmbrellaCachemapMixin
        def sync_cachemap(sdks: [])
          UI.section("Syncing cachemap (sdks: #{sdks.map(&:name)})")
          nodes, edges, parents = xccache_desc.traverse
          cache_data = gen_cache_data(nodes, parents, sdks)
          targets_data, macros_data, deps_data = {}, {}, {}
          xccache_desc.targets.each do |agg_target|
            targets, macros = [], []
            agg_target.direct_dependencies.each do |d|
              all_hit = d.recursive_targets.all? { |t| cache_data[t] == :hit }
              # If any associated targets is missed -> use original product form
              # Otherwise, replace with recursive targets' binaries
              deps_data[d.full_name] = d.recursive_targets.map(&:xccache_id)
              targets << (all_hit ? "#{d.full_name}.binary" : d.full_name)
              macros += d.recursive_targets.select(&:macro?).map(&:full_name) if all_hit
            end
            targets_data[agg_target.name] = targets.uniq.sort_by(&:downcase)
            macros_data[agg_target.name] = macros.uniq
          end

          config.cachemap.raw = {
            "manifest" => {
              "targets" => targets_data,
              "macros" => macros_data,
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

        def gen_cache_data(nodes, parents, sdks)
          result = nodes.to_h do |node|
            res = if config.ignore?(node.full_name) then :ignored
                  else
                    verify_binary?(node, sdks) ? :hit : :missed
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

        def verify_binary?(target, sdks)
          return true if target.binary?

          bpath = binary_path(target.xccache_id)
          bpath_with_checksum = binary_path(target.xccache_id, checksum: target.checksum, in_repo: true)

          check = proc do
            # For macro, we just need the tool binary to exist
            # For regular targets, the xcframework must satisfy the sdk constraints (ie. containing all the slices)
            next bpath_with_checksum.exist? if target.macro?

            metadata = XCFramework::Metadata.new(bpath_with_checksum / "Info.plist")
            expected_triples = sdks.map { |sdk| sdk.triple(without_vendor: true) }
            missing_triples = expected_triples - metadata.triples
            missing_triples.empty?
          end

          # If requirements are meet, create symlink `A-abc123.xcframework` -> `A.framework`
          # Otherwise, remove symlink `A.xcframework`
          if check.call
            bpath_with_checksum.symlink_to(bpath)
          elsif bpath.exist?
            bpath.rmtree
          end
          bpath.exist?
        end

        def binary_path(name, checksum: nil, in_repo: false)
          suffix = checksum.nil? ? "" : "-#{checksum}"
          ext = File.extname(name) == ".macro" ? ".macro" : ".xcframework"
          binaries_dir = in_repo ? config.spm_cache_dir : config.spm_binaries_dir
          p = binaries_dir / File.basename(name, ".*")
          p / "#{p.basename}#{suffix}#{ext}"
        end

        def target_to_cytoscape_node(x, cache_data)
          h = { :id => x.full_name, :cache => cache_data[x] }
          h[:type] = if x.name.end_with?(".xccache") then "agg"
                     elsif x.macro? then "macro" end
          h[:checksum] = x.checksum
          h[:binary] = binary_path(x.xccache_id) if cache_data[x] == :hit
          h
        end
      end
    end
  end
end
