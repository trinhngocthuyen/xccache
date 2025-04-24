module XCCache
  module SPM
    class Package
      module UmbrellaManifestMixin
        def write_manifest(force: false)
          return if @did_write_manifest && !force

          UI.message("Writing Package.swift (package: #{root_dir.basename.to_s.dark})")
          Template.new("umbrella.Package.swift").render(
            {
              :json => manifest_targets_json,
              :platforms => manifest_platforms,
              :dependencies => manifest_pkg_dependencies,
              :swift_version => Swift::Swiftc.version_without_patch,
            },
            save_to: root_dir / "Package.swift",
          )
          @did_write_manifest = true
        end

        def manifest_targets_json
          # Initially, write json with the original data in lockfile (without cache)
          data = @did_write_manifest ? config.cachemap.targets_data : config.lockfile.targets_data
          JSON.pretty_generate("targets" => data)
        end

        def manifest_pkg_dependencies
          decl = proc do |hash|
            if (path_from_root = hash["path_from_root"])
              absolute_path = (Pathname(".") / path_from_root).expand_path
              next ".package(path: \"#{absolute_path}\")"
            end

            requirement = hash["requirement"]
            case requirement["kind"]
            when "upToNextMajorVersion"
              opt = ".upToNextMajor(from: \"#{requirement['minimumVersion']}\")"
            when "upToNextMinorVersion"
              opt = ".upToNextMinor(from: \"#{requirement['minimumVersion']}\")"
            when "exactVersion"
              opt = "exact: \"#{requirement['version']}\""
            when "branch"
              opt = "branch: \"#{requirement['branch']}\""
            when "revision"
              opt = "revision: \"#{requirement['revision']}\""
            when "versionRange"
              opt = "\"#{requirement['minimumVersion']}\"..<\"#{requirement['maximumVersion']}\""
            end
            ".package(url: \"#{hash['repositoryURL']}\", #{opt})"
          end

          config.lockfile.pkgs.map { |h| "  #{decl.call(h)}," }.join("\n")
        end

        def manifest_platforms
          @manifest_platforms ||= begin
            hash = config.projects.flat_map(&:targets).to_h { |t| [t.platform_name, t.deployment_target] }
            items = hash.map do |name, version|
              major_version = version.split(".")[0]
              platform = {
                :ios => "iOS",
                :macos => "macOS",
                :osx => "macOS",
                :tvos => "tvOS",
                :watchos => "watchOS",
                :visionos => "visionOS",
              }[name]
              ".#{platform}(.v#{major_version})"
            end
            items.map { |x| "  #{x}," }.join("\n")
          end
        end
      end
    end
  end
end
