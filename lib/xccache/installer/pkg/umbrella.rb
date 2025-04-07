require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"
require "xccache/spm/package"

module XCCache
  class UmbrellaPkg
    attr_reader :path, :projects, :cachemap

    def initialize(options)
      @path = options[:path]
      @projects = options[:projects]
      @cachemap = options[:cachemap]
      @pkg = SPM::Package.new(root_dir: @path)
    end

    def prepare
      create!
      resolve
    end

    def resolve
      UI.message("Resolving umbrella package dependencies...")
      Sh.run("swift package resolve --package-path #{path} 2>&1")
    end

    def build(options = {})
      @pkg.build(options)
    end

    private

    def create!
      UI.message("Create umbrella package at #{path}".cyan)
      Template.new("umbrella.Package.swift").render(
        {
          :dependencies => pkg_dependencies,
          :swift_version => Swift::Swiftc.version_without_patch,
        },
        save_to: path / "Package.swift",
      )
    end

    def checkouts_dir
      @checkouts_dir ||= path / ".build" / "checkouts"
    end

    def pkg_dependencies
      decl = proc do |pkg|
        # FIXME: relative_path should be adjusted
        return ".package(path: \"#{pkg.relative_path}\")" if pkg.local?

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
