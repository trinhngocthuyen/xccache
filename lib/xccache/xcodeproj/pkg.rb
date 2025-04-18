require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      module PkgRefMixin
        def id
          local? ? (relative_path || path) : repositoryURL
        end

        def slug
          File.basename(id, File.extname(id))
        end

        def local?
          is_a?(XCLocalSwiftPackageReference)
        end

        def xccache_pkg?
          local? && id == "xccache/packages/umbrella"
        end

        def create_pkg_product_dependency_ref(product)
          ref = project.new(XCSwiftPackageProductDependency)
          ref.package = self
          ref.product_name = product
          ref
        end

        def create_target_dependency_ref(product)
          ref = project.new(PBXTargetDependency)
          ref.name = product
          ref.product_ref = create_pkg_product_dependency_ref(product)
          ref
        end
      end

      class XCLocalSwiftPackageReference
        include PkgRefMixin

        def ascii_plist_annotation
          # Workaround: Xcode is using display_name while Xcodeproj is using File.basename(display_name)
          # Here, the plugin forces to use display_name so that updates either by Xcode or Xcodeproj are consistent
          " #{isa} \"#{display_name}\" "
        end

        def to_h
          {
            "relative_path" => relative_path,
            "path" => path,
            "path_from_root" => absolute_path.relative_path_from(Pathname(".").expand_path).to_s,
          }
        end

        def absolute_path
          path.nil? ? project.path.parent / relative_path : path
        end
      end

      class XCRemoteSwiftPackageReference
        include PkgRefMixin

        def to_h
          { "repositoryURL" => repositoryURL, "requirement" => requirement }
        end
      end
    end
  end
end
