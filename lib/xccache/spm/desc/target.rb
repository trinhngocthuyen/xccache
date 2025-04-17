require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Target < BaseObject
        include Cacheable
        cacheable :recursive_targets

        def type
          @type ||= raw["type"].to_sym
        end

        def bundle_name
          "#{pkg_name}_#{name}.bundle"
        end

        def sources_path
          @sources_path ||= begin
            path = raw["path"] || "Sources/#{name}"
            root.src_dir / path
          end
        end

        def use_clang?
          !header_paths.empty?
        end

        def header_paths
          @header_paths ||=
            (header_search_paths + public_header_paths)
            .flat_map { |p| p.glob("**/*.h*") }
            .map(&:realpath)
            .uniq
        end

        def settings
          raw["settings"]
        end

        def header_search_paths
          @header_search_paths ||=
            settings
            .filter_map { |h| h.fetch("kind", {})["headerSearchPath"] }
            .flat_map(&:values)
            .map { |p| sources_path / p }
        end

        def public_header_paths
          @public_header_paths ||= begin
            res = []
            implicit_path = sources_path / "include"
            res << implicit_path unless implicit_path.glob("**/*.h*").empty?
            res << (sources_path / raw["publicHeadersPath"]) if raw.key?("publicHeadersPath")
            res
          end
        end

        def resource_paths
          @resource_paths ||= begin
            res = raw.fetch("resources", []).map { |h| sources_path / h["path"] }
            # Refer to the following link for the implicit resources
            # https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package#Add-resource-files
            implicit = sources_path.glob("*.{xcassets,xib,storyboard,xcdatamodeld,lproj}")
            res + implicit
          end
        end

        def recursive_targets(platform: nil)
          raw["dependencies"].flat_map do |hash|
            dep_type = ["byName", "target", "product"].find { |k| hash.key?(k) }
            if dep_type.nil?
              raise GeneralError, "Unexpected dependency type. Must be either `byName`, `target`, or `product`."
            end
            next [] unless match_platform?(hash[dep_type][-1], platform)

            name = hash[dep_type][0]
            pkg_name = hash.key?("product") ? hash["product"][1] : self.pkg_name
            pkg_desc = pkg_desc_of(pkg_name)
            find_by_target = -> { pkg_desc.targets.select { |t| t.name == name } }
            find_by_product = -> { pkg_desc.targets_of_product(name) }
            next find_by_target.call if hash.key?("target")
            next find_by_product.call if hash.key?("product")

            # byName, could be either a target or a product
            next find_by_target.call || find_by_product.call
          end
        end

        def match_platform?(_condition, _platform)
          true # FIXME: Handle this
        end
      end
    end
  end
end
