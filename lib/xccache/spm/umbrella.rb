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
      @descs = []
    end

    def prepare(options = {})
      UI.section("Preparing umbrella package".bold) do
        create!
        create_symlinks_to_local_pkgs
        resolve
      end
      gen_metadata if options[:gen_metadata]
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
          UI.message("Generating metadata of #{dir.basename}")
          desc = SPM::Package::Description.in_dir(dir)
          next if desc.nil?

          @descs << desc
          desc.save
          desc.save(to: desc.path.parent / "#{desc.name}.json") if desc.name != dir.basename.to_s
        end
      end
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
