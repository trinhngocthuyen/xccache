require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Description < BaseObject
        include Cacheable
        cacheable :resolve_recursive_dependencies

        def self.descs_in_metadata_dir
          descs = Config.instance.spm_metadata_dir.glob("*.json").map { |p| Description.new(p) }
          [descs, combine_descs(descs)]
        end

        def self.in_dir(dir, save_to_dir: nil)
          path = save_to_dir / "#{dir.basename}.json" unless save_to_dir.nil?
          begin
            raw = JSON.parse(Sh.capture_output("swift package dump-package --package-path #{dir}"))
            Description.new(path, raw: raw)
          rescue StandardError => e
            UI.error("Failed to dump package in #{dir}. Error: #{e}")
          end
        end

        def self.descs_in_dir(root_dir, save_to_dir: nil)
          dirs = [root_dir] + root_dir.glob(".build/checkouts/*").reject { |p| p.glob("Package*.swift").empty? }
          descs = dirs.parallel_map do |dir|
            desc = Description.in_dir(dir, save_to_dir: save_to_dir)
            unless save_to_dir.nil?
              desc.save
              desc.save(to: desc.path.parent / "#{desc.name}.json") if desc.name != dir.basename.to_s
            end
            desc
          end
          [descs, combine_descs(descs)]
        end

        def root
          self
        end

        def metadata
          raw["_metadata"] ||= {}
        end

        def dependencies
          @dependencies ||= fetch("dependencies", Dependency)
        end

        def uniform_dependencies
          dependencies.filter_map(&:pkg_desc)
        end

        def products
          @products ||= fetch("products", Product)
        end

        def targets
          @targets ||= fetch("targets", Target).map(&:downcast)
        end

        def binary_targets
          @binary_targets ||= targets.select(&:binary?)
        end

        def has_target?(name)
          targets.any? { |t| t.name == name }
        end

        def get_target(name)
          targets.find { |t| t.name == name }
        end

        def targets_of_products(name)
          matched_products = products.select { |p| p.name == name }
          matched_products
            .flat_map { |p| targets.select { |t| p.target_names.include?(t.name) } }
        end

        def resolve_recursive_dependencies(platform: nil)
          products.to_h { |p| [p, p.recursive_targets(platform: platform)] }
        end

        def local?
          # Workaround: If the pkg dir is under the build checkouts dir -> remote
          !src_dir.to_s.start_with?((config.spm_build_dir / "checkouts").to_s)
        end

        def traverse
          nodes, edges, parents = [], [], {}
          to_visit = targets.dup
          visited = Set.new
          until to_visit.empty?
            cur = to_visit.pop
            next if visited.include?(cur)

            visited << cur
            nodes << cur
            yield cur if block_given?

            # For macro impl, we don't need their dependencies, just the tool binary
            # So, no need to care about swift-syntax dependencies
            next if cur.macro?
            cur.direct_dependency_targets.each do |t|
              to_visit << t
              edges << [cur, t]
              parents[t] ||= []
              parents[t] << cur
            end
          end
          [nodes, edges, parents]
        end

        def git
          @git ||= Git.new(src_dir) if Dir.git?(src_dir)
        end

        def self.combine_descs(descs)
          descs_by_name = descs.flat_map { |d| [[d.name, d], [d.pkg_slug, d]] }.to_h
          descs.each { |d| d.retrieve_pkg_desc = proc { |name| descs_by_name[name] } }
          descs_by_name
        end
      end
    end
  end
end
