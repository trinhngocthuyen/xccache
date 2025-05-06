require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Target < BaseObject
        include Cacheable
        cacheable :recursive_targets, :direct_dependency_targets, :direct_dependencies

        def xccache?
          name.end_with?(".xccache")
        end

        def type
          @type ||= raw["type"].to_sym
        end

        def module_name
          name.c99extidentifier
        end

        def resource_bundle_name
          "#{pkg_name}_#{name}.bundle"
        end

        def flatten_as_targets
          [self]
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

        def header_paths(options = {})
          paths = []
          paths += public_header_paths if options.fetch(:public, true)
          paths += header_search_paths if options.fetch(:search, false)
          paths
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
          children = direct_dependency_targets(platform: platform)
          children += children.flat_map { |t| t.recursive_targets(platform: platform) }
          children.uniq
        end

        def direct_dependencies(platform: nil)
          raw["dependencies"].flat_map do |hash|
            dep_types = ["byName", "target", "product"]
            if (dep_type = dep_types.intersection(hash.keys).first).nil?
              raise GeneralError, "Unexpected dependency type. Must be one of #{dep_types}. Hash: #{hash}"
            end
            next [] unless match_platform?(hash[dep_type][-1], platform)
            pkg_name = hash[dep_type][1] if dep_type == "product"
            find_deps(hash[dep_type][0], pkg_name, dep_type)
          end
        end

        def direct_dependency_targets(platform: nil)
          direct_dependencies(platform: platform).flat_map(&:flatten_as_targets).uniq
        end

        def match_platform?(_condition, _platform)
          true # FIXME: Handle this
        end

        def binary?
          type == :binary
        end

        def binary_path
          sources_path if binary?
        end

        def local_binary_path
          binary_path if binary? && root.local?
        end

        def checksum
          @checksum ||= root.git&.sha || sources_path.checksum
        end

        private

        def find_deps(name, pkg_name, dep_type)
          # If `dep_type` is `target` -> constrained within current pkg only
          # If `dep_type` is `product` -> `pkg_name` must be present
          # If `dep_type` is `byName` -> it's either from this pkg, or its children/dependencies
          res = []
          descs = pkg_name.nil? ? [root] + root.uniform_dependencies : [pkg_desc_of(pkg_name)]
          descs.each do |desc|
            by_target = -> { desc.targets.select { |t| t.name == name } }
            by_product = -> { desc.products.select { |t| t.name == name } }
            return by_target.call if dep_type == "target"
            return by_product.call if dep_type == "product"
            return res unless (res = by_target.call).empty?
            return res unless (res = by_product.call).empty?
          end
          []
        end
      end
    end
  end
end
