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
      @pkg_descs = []
      @pkg_descs_by_name = {}
      @dependencies ||= {}
      @raw_dependencies ||= {}
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
      return UI.warn("No targets to build. Possibly because cache was all hit") if to_build.empty?

      UI.info("-> Targets to build: #{to_build.to_s.bold}")
      pkg.build(options.merge(:targets => to_build))
      sync_cachemap
    end

    def sync_cachemap
      UI.section("Syncing cachemap")
      cachemap.sync!(lockfile, projects, @raw_dependencies)
    end

    def targets_to_build(options)
      items = options[:targets]
      items = cachemap.missed if items.nil? || items.empty?
      items = items.split(",") if items.is_a?(String)
      to_discard = items.select { |x| config.ignore?(x) }
      unless to_discard.empty?
        UI.message("Don't build #{to_discard.to_s.dark} (reason: ignored in the config)")
        items = items.difference(to_discard)
      end

      items.map do |name|
        @pkg_descs.flat_map(&:targets).find { |p| p.name == name }.full_name
      end
    end

    def gen_metadata
      UI.section("Generating metadata of packages") do
        checkouts_dirs.each do |dir|
          pkg_desc = SPM::Package::Description.in_dir(dir, save_to_dir: config.spm_metadata_dir)
          next if pkg_desc.nil?

          pkg_desc.retrieve_pkg_desc = proc { |name| @pkg_descs_by_name[name] }
          pkg_desc.save
          pkg_desc.save(to: pkg_desc.path.parent / "#{pkg_desc.name}.json") if pkg_desc.name != dir.basename.to_s
          @pkg_descs << pkg_desc
          @pkg_descs_by_name[pkg_desc.name] = pkg_desc
          @pkg_descs_by_name[dir.basename.to_s] = pkg_desc
        end
      end
    end

    def resolve_recursive_dependencies
      gen_metadata
      UI.section("Resolving recursive dependencies") do
        @pkg_descs.each do |pkg_desc|
          @dependencies.merge!(pkg_desc.resolve_recursive_dependencies)
        end
      end
      @raw_dependencies = @dependencies.to_h { |k, v| [k.full_name, v.map(&:full_name)] }
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

    def manifest_targets_json
      data = cachemap.cache_data.values.flat_map do |hash|
        hash.map do |target_name, deps|
          deps = deps.reject { |d| cachemap.miss?(d) && lockfile.implicit_dependency?(d) }
          ["#{target_name}.xccache", deps]
        end
      end.to_h
      JSON.pretty_generate("targets" => data)
    end

    def manifest_pkg_dependencies
      decl = proc do |pkg|
        next ".package(path: \"#{pkg.absolute_path}\")" if pkg.local?

        requirement = pkg.requirement
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
        ".package(url: \"#{pkg.repositoryURL}\", #{opt})"
      end

      projects.flat_map(&:non_xccache_pkgs).map { |x| "  #{decl.call(x)}," }.join("\n")
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
