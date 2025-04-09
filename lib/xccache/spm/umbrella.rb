require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"
require "xccache/spm/build"

module XCCache
  class UmbrellaPkg
    attr_reader :path, :projects, :cachemap, :metadata_dir

    def initialize(options)
      @path = options[:path]
      @projects = options[:projects]
      @cachemap = options[:cachemap]
      @pkg = SPM::Package.new(root_dir: @path)
      @metadata_dir = options[:metadata_dir]
      @pkg_descs = []
      @pkg_descs_by_name = {}
      @dependencies ||= {}
    end

    def prepare
      UI.section("Preparing umbrella package".bold) do
        create!
        create_symlinks_to_local_pkgs
        resolve
      end
    end

    def resolve
      UI.section("Resolving umbrella package dependencies") do
        Sh.run("swift package resolve --package-path #{path} 2>&1")
      end
    end

    def build(options = {})
      @pkg.build(options)
    end

    def gen_metadata
      UI.section("Generating metadata of packages".bold) do
        checkouts_dirs.each do |dir|
          UI.message("-> Package: #{dir.basename}".dark)
          pkg_desc = SPM::Package::Description.in_dir(dir)
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
      UI.section("Resolving recursive dependencies".bold) do
        @pkg_descs.each do |pkg_desc|
          UI.message("-> Package: #{pkg_desc.name}".dark)
          @dependencies.merge!(pkg_desc.resolve_recursive_dependencies)
        end
      end
      @raw_dependencies = @dependencies.to_h { |k, v| [k.full_name, v.map(&:full_name)] }
    end

    def gen_cachemap(lockfile)
      UI.section("Generating cachemap".bold)
      projects.each do |project|
        target_deps = lockfile[project.display_name]["dependencies"].to_h do |target_name, products|
          deps = products.flat_map { |p| @raw_dependencies[p] || [] }
          [target_name, deps]
        end
        cachemap[project.display_name] = target_deps
      end
      cachemap.save
    end

    private

    def checkouts_dir
      @checkouts_dir ||= path / ".build" / "checkouts"
    end

    def local_checkouts_dir
      @local_checkouts_dir ||= Dir.prepare(path / ".local")
    end

    def checkouts_dirs
      (checkouts_dir.glob("*") + local_checkouts_dir.glob("*")).reject do |p|
        p.glob("Package*.swift").empty?
      end
    end

    def create!
      UI.message("Creating umbrella package at #{path}".cyan)
      Template.new("umbrella.Package.swift").render(
        {
          :dependencies => pkg_dependencies,
          :swift_version => Swift::Swiftc.version_without_patch,
        },
        save_to: path / "Package.swift",
      )
    end

    def create_symlinks_to_local_pkgs
      projects.flat_map(&:pkgs).select(&:local?).reject(&:xccache_pkg?).uniq(&:slug).each do |pkg|
        symlink_dir = local_checkouts_dir / File.basename(pkg.absolute_path)
        symlink_dir.rmtree if symlink_dir.exist?
        File.symlink(pkg.absolute_path, symlink_dir)
      end
    end

    def pkg_dependencies
      decl = proc do |pkg|
        next "    .package(path: \"#{pkg.absolute_path}\")" if pkg.local?

        requirement = pkg.requirement
        case requirement["kind"]
        when "upToNextMajorVersion"
          opt = ".upToNextMajor(from: \"#{requirement['minimumVersion']}\")"
        when "upToNextMinorVersion"
          opt = ".upToNextMinor(from: \"#{pkg.requirement['minimumVersion']}\")"
        when "exactVersion"
          opt = "exact: #{pkg.requirement['version']}"
        when "branch"
          opt = "branch: \"#{pkg.requirement['branch']}\""
        when "revision"
          opt = "revision: #{pkg.requirement['revision']}"
        when "versionRange"
          opt = "\"#{pkg.requirement['minimumVersion']}\"..<\"#{pkg.requirement['maximumVersion']}\""
        end
        "    .package(url: \"#{pkg.repositoryURL}\", #{opt}),"
      end

      projects.flat_map(&:non_xccache_pkgs).map { |x| decl.call(x) }.join("\n")
    end
  end
end
