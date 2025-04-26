require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Description < BaseObject
        include Cacheable
        cacheable :resolve_recursive_dependencies

        def self.in_dir(dir, save_to_dir: nil, checksum: true)
          path = save_to_dir / "#{dir.basename}.json" unless save_to_dir.nil?
          begin
            raw = JSON.parse(Sh.capture_output("swift package dump-package --package-path #{dir}"))
            this = Description.new(path, raw: raw)
            this.calc_checksum if checksum
            this
          rescue StandardError => e
            UI.error("Failed to dump package in #{dir}. Error: #{e}")
          end
        end

        def root
          self
        end

        def metadata
          raw["_metadata"] ||= {}
        end

        def checksum
          metadata["checksum"]
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
          @targets ||= fetch("targets", Target)
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

        def calc_checksum
          metadata["checksum"] = git.nil? ? src_dir.checksum : git.sha
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
            cur.direct_dependency_targets.each do |t|
              to_visit << t
              edges << [cur, t]
              parents[t] ||= []
              parents[t] << cur
            end
          end
          [nodes, edges, parents]
        end

        private

        def git
          @git ||= Git.new(src_dir) if Dir.git?(src_dir)
        end
      end
    end
  end
end
