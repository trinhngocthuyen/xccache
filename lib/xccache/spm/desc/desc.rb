require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Description < BaseObject
        def self.in_dir(dir)
          path = Config.instance.spm_metadata_dir / "#{dir.basename}.json"
          begin
            raw = JSON.parse(Sh.capture_output("swift package dump-package --package-path #{dir}"))
            Description.new(path, raw: raw)
          rescue StandardError => e
            UI.error("Failed to dump package in #{dir}. Error: #{e}")
          end
        end

        def root
          self
        end

        def products
          @products ||= fetch("products", Product)
        end

        def targets
          @targets ||= fetch("targets", Target)
        end

        def has_target?(name)
          targets.any? { |t| t.name == name }
        end

        def get_target(name)
          targets.find { |t| t.name == name }
        end

        def targets_of_product(name)
          matched_products = products.select { |p| p.name == name }
          matched_products
            .flat_map { |p| targets.select { |t| p.target_names.include?(t.name) } }
        end

        def resolve_recursive_dependencies(platform: nil)
          products.to_h { |p| [p, p.recursive_targets(platform: platform)] }
        end
      end
    end
  end
end
