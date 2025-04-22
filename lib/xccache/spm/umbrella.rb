require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"
require "xccache/spm/build"

module XCCache
  class UmbrellaPkg
    include Config::Mixin
    attr_reader :path, :projects, :lockfile, :cachemap, :pkg, :metadata_dir

    def initialize
      @path = config.spm_umbrella_sandbox
      @projects = config.projects
      @lockfile = config.lockfile
      @cachemap = config.cachemap
      @pkg = SPM::Package.new(root_dir: @path)
      @metadata_dir = config.spm_metadata_dir
      @pkg_group = nil
    end

    def prepare
      UI.section("Preparing umbrella package") do
        create
        resolve
      end
      resolve_recursive_dependencies
      sync_cachemap
    end

    def resolve
      pkg.resolve
      create_symlinks
    end

    def build(options = {})
      to_build = targets_to_build(options)
      return UI.warn("No targets to build, possibly due to all-hit for non-ignored targets/products") if to_build.empty?

      UI.info("-> Targets to build: #{to_build.to_s.bold}")
      pkg.build(options.merge(:targets => to_build))
      sync_cachemap
    end

    def sync_cachemap
      UI.section("Syncing cachemap")
      cachemap.sync!(lockfile, @pkg_group)
    end

    def targets_to_build(options)
      items = options[:targets]
      items = cachemap.missed_targets if items.nil? || items.empty?
      items = items.split(",") if items.is_a?(String)
      items.map do |name|
        @pkg_group.descs.flat_map(&:targets).find { |p| p.name == name }.full_name
      end
    end

    def gen_metadata
      UI.section("Generating metadata of packages") do
        @pkg_group = SPM::Package::Group.in_checkouts_dir(
          config.spm_build_dir / "checkouts",
          save_to_dir: config.spm_metadata_dir,
        )
      end
    end

    def resolve_recursive_dependencies
      gen_metadata
      UI.section("Resolving recursive dependencies") do
        @pkg_group.resolve_recursive_dependencies
      end
      create_symlinks_to_artifacts
    end

    def write_manifest(force: false)
      return if @did_write_manifest && !force

      UI.message("Writing Package.swift (package: #{path.basename.to_s.dark})")
      Template.new("umbrella.Package.swift").render(
        {
          :json => manifest_targets_json,
          :platforms => manifest_platforms,
          :dependencies => manifest_pkg_dependencies,
          :swift_version => Swift::Swiftc.version_without_patch,
        },
        save_to: path / "Package.swift",
      )
      @did_write_manifest = true
    end

    private

    def checkouts_dir
      @checkouts_dir ||= path / ".build" / "checkouts"
    end

    def checkouts_dirs
      checkouts_dir.glob("*").reject { |p| p.glob("Package*.swift").empty? }
    end

    def create
      write_manifest
      # Create dummy sources dirs prefixed with `.` so that they do not show up in Xcode
      projects.flat_map(&:targets).each do |target|
        dir = Dir.prepare(path / ".Sources" / "#{target.product_name}.xccache")
        (dir / "dummy.swift").write("")
      end
    end

    def create_symlinks
      # Symlinks for convenience
      (path / "binaries").symlink_to(path.parent / "binaries")
      (path / ".build").symlink_to(path.parent / ".build")
      (path / ".build/checkouts").symlink_to(path.parent / "checkouts")
    end

    def create_symlinks_to_artifacts
      # Clean up broken symlinks
      config.spm_binaries_frameworks_dir.glob("*/*.xcframework").each do |p|
        p.rmtree if p.symlink? && !p.readlink.exist?
      end

      binary_targets = @pkg_group.binary_targets
      UI.message("Creating symlinks to binary artifacts of targets: #{binary_targets.map(&:full_name).to_s.dark}")
      binary_targets.each do |target|
        dst_path = config.spm_binaries_frameworks_dir / target.name / "#{target.name}.xcframework"
        # For local xcframework, just symlink to the path
        # Zip frameworks (either of local or remote pkgs) are unzipped in the build artifacts
        target.local_binary_path.symlink_to(dst_path) if target.local_binary_path&.extname == ".xcframework"
        config.spm_artifacts_dir.glob("#{target.full_name}/*.xcframework").each do |p|
          p.symlink_to(dst_path)
        end
      end
    end

    def manifest_targets_json
      # Initially, write json with the original data in lockfile (without cache)
      data = @did_write_manifest ? cachemap.targets_data : lockfile.targets_data
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
          opt = "exact: #{requirement['version']}"
        when "branch"
          opt = "branch: \"#{requirement['branch']}\""
        when "revision"
          opt = "revision: #{requirement['revision']}"
        when "versionRange"
          opt = "\"#{requirement['minimumVersion']}\"..<\"#{requirement['maximumVersion']}\""
        end
        ".package(url: \"#{hash['repositoryURL']}\", #{opt})"
      end

      lockfile.pkgs.map { |h| "  #{decl.call(h)}," }.join("\n")
    end

    def manifest_platforms
      @manifest_platforms ||= begin
        hash = projects.flat_map(&:targets).to_h { |t| [t.platform_name, t.deployment_target] }
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
