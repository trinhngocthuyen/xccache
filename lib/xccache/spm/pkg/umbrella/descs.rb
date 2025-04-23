module XCCache
  module SPM
    class Package
      module UmbrellaDescsMixin
        def gen_metadata
          UI.section("Generating metadata of packages") do
            dirs = [root_dir] + root_dir.glob(".build/checkouts/*").reject { |p| p.glob("Package*.swift").empty? }
            dirs.each do |dir|
              desc = Description.in_dir(dir, save_to_dir: config.spm_metadata_dir)
              next if desc.nil?

              desc.retrieve_pkg_desc = proc { |name| @descs_by_name[name] }
              desc.save
              desc.save(to: desc.path.parent / "#{desc.name}.json") if desc.name != dir.basename.to_s
              @descs << desc
              @descs_by_name[desc.name] = desc
              @descs_by_name[dir.basename.to_s] = desc
            end
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
