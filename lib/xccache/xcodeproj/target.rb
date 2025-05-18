require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class PBXNativeTarget
        alias pkg_product_dependencies package_product_dependencies

        def non_xccache_pkg_product_dependencies
          pkg_product_dependencies.reject { |d| d.pkg&.xccache_pkg? }
        end

        def has_xccache_product_dependency?
          pkg_product_dependencies.any? { |d| d.pkg&.xccache_pkg? }
        end

        def has_pkg_product_dependency?(name)
          pkg_product_dependencies.any? { |d| d.full_name == name }
        end

        def add_pkg_product_dependency(name)
          Log.message("(+) Add dependency #{name.blue} to target #{display_name.bold}")
          pkg_name, product_name = name.split("/")
          pkg = project.get_pkg(pkg_name)
          pkg_product_dependencies << pkg.create_target_dependency_ref(product_name).product_ref
        end

        def add_xccache_product_dependency
          add_pkg_product_dependency("umbrella/#{name}.xccache")
        end

        def remove_xccache_product_dependencies
          remove_pkg_product_dependencies { |d| d.pkg&.xccache_pkg? }
        end

        def remove_pkg_product_dependencies(&block)
          package_product_dependencies.select(&block).each(&:remove_alongside_related)
        end
      end
    end
  end
end
