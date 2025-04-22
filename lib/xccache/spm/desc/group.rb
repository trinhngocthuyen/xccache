require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Group
        attr_reader :descs, :descs_by_name

        def initialize(descs, descs_by_name)
          @descs = descs
          @descs_by_name = descs_by_name
          @dependency_targets_by_products = {}
        end

        def self.in_checkouts_dir(checkouts_dir, save_to_dir: nil)
          descs, descs_by_name = [], {}
          checkouts_dir.glob("*").reject { |p| p.glob("Package*.swift").empty? }.each do |dir|
            desc = Description.in_dir(dir, save_to_dir: save_to_dir)
            next if desc.nil?

            desc.retrieve_pkg_desc = proc { |name| descs_by_name[name] }
            desc.save
            desc.save(to: desc.path.parent / "#{desc.name}.json") if desc.name != dir.basename.to_s
            descs << desc
            descs_by_name[desc.name] = desc
            descs_by_name[dir.basename.to_s] = desc
          end
          Group.new(descs, descs_by_name)
        end

        def resolve_recursive_dependencies
          descs.each do |desc|
            @dependency_targets_by_products.merge!(desc.resolve_recursive_dependencies.transform_keys(&:full_name))
          end
        end

        def targets_of_products(products)
          products = [products] if products.is_a?(String)
          products.flat_map { |x| desc_of(x).targets_of_products(File.basename(x)) }
        end

        def dependency_targets_of_products(products)
          products = [products] if products.is_a?(String)
          products.flat_map { |p| @dependency_targets_by_products[p] || [p] }.uniq
        end

        def desc_of(d)
          @descs_by_name[File.dirname(d)]
        end

        def binary_targets
          @descs_by_name.values.flatten.uniq.flat_map(&:binary_targets)
        end
      end
    end
  end
end
