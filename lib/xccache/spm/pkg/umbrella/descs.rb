module XCCache
  module SPM
    class Package
      module UmbrellaDescsMixin
        def gen_metadata
          UI.section("Generating metadata of packages", timing: true) do
            @descs, @descs_by_name = Description.descs_in_dir(root_dir, save_to_dir: config.spm_metadata_dir)
          end
        end

        def xccache_desc
          @xccache_desc ||= desc_of("xccache")
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
          @descs_by_name[d.split("/").first]
        end

        def binary_targets
          @descs_by_name.values.flatten.uniq.flat_map(&:binary_targets)
        end
      end
    end
  end
end
