Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }
require_relative "proxy_executable"

module XCCache
  module SPM
    class Package
      class Proxy < Package
        module Mixin
          def xccache_proxy
            @xccache_proxy ||= Executable.new
          end
        end

        include Mixin

        def umbrella
          @umbrella ||= Package.new(root_dir: config.spm_umbrella_sandbox)
        end

        def prepare(options = {})
          xccache_proxy.run("gen-umbrella")
          umbrella.resolve
          invalidate_cache(sdks: options[:sdks])
          gen_proxy
        end

        def gen_proxy
          xccache_proxy.run("gen-proxy")
          config.cachemap.update_from_graph(graph.reload)
        end

        def invalidate_cache(sdks: [])
          UI.message("Invalidating cache (sdks: #{sdks.map(&:name)})")

          config.spm_cache_dir.glob("*/*.{xcframework,macro}").each do |p|
            cmps = p.basename(".*").to_s.split("-")
            name, checksum = cmps[...-1].join("-"), cmps[-1]
            p_without_checksum = config.spm_binaries_dir / name / "#{name}#{p.extname}"
            accept_cache = proc { p.symlink_to(p_without_checksum) }
            reject_cache = proc { p_without_checksum.rmtree if p_without_checksum.exist? }
            next reject_cache.call if (target = umbrella.get_target(name)).nil?
            next reject_cache.call if target.checksum != checksum
            # For macro, we just need the tool binary to exist
            next accept_cache.call if target.macro?

            # For regular targets, the xcframework must satisfy the sdk constraints (ie. containing all the slices)
            metadata = XCFramework::Metadata.new(p / "Info.plist")
            expected_triples = sdks.map { |sdk| sdk.triple(without_vendor: true) }
            missing_triples = expected_triples - metadata.triples
            missing_triples.empty? ? accept_cache.call : reject_cache.call
          end
        end

        def graph
          @graph ||= JSONRepresentable.new(root_dir / "graph.json")
        end
      end
    end
  end
end
