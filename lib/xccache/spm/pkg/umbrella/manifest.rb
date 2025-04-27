module XCCache
  module SPM
    class Package
      module UmbrellaManifestMixin
        def write_manifest(no_cache: false)
          UI.info("Writing Package.swift (package: #{root_dir.basename.to_s.dark})")
          Template.new("umbrella.Package.swift").render(
            {
              :json => manifest_targets_json(no_cache: no_cache),
              :platforms => manifest_platforms,
              :dependencies => manifest_pkg_dependencies,
              :swift_version => Swift::Swiftc.version_without_patch,
            },
            save_to: root_dir / "Package.swift",
          )
        end

        def manifest_targets_json(no_cache: false)
          data = no_cache ? config.lockfile.targets_data : config.cachemap.targets_data
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
            to_spm_platform = {
              :ios => "iOS",
              :macos => "macOS",
              :osx => "macOS",
              :tvos => "tvOS",
              :watchos => "watchOS",
              :visionos => "visionOS",
            }
            hash = {}
            config.project_targets.each do |t|
              platform = to_spm_platform[t.platform_name]
              hash[platform] ||= []
              hash[platform] << t.deployment_target.split(".")[0]
            end
            hash
              .transform_values(&:min)
              .map { |platform, version| "  .#{platform}(.v#{version})," }
              .join("\n")
          end
        end
      end
    end
  end
end
