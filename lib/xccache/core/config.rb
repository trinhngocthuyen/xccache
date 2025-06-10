require "xcodeproj"
require "xccache/core/syntax/yml"

module XCCache
  class Config < YAMLRepresentable
    module Mixin
      def config
        Config.instance
      end
    end

    def self.instance
      @instance ||= new(Pathname("xccache.yml").expand_path)
    end

    attr_accessor :verbose, :ansi
    alias verbose? verbose
    alias ansi? ansi

    # To distinguish if it's within an installation, or standalone like `xccache pkg build`
    attr_accessor :in_installation
    alias in_installation? in_installation

    attr_writer :install_config

    def ensure_file!
      Template.new("xccache.yml").render(save_to: path) unless path.exist?
    end

    def install_config
      @install_config || "debug"
    end

    def sandbox
      @sandbox = Dir.prepare("xccache").expand_path
    end

    def spm_sandbox
      @spm_sandbox ||= Dir.prepare(sandbox / "packages").expand_path
    end

    def spm_local_pkgs_dir
      @spm_local_pkgs_dir ||= Dir.prepare(spm_sandbox / "local")
    end

    def spm_xcconfigs_dir
      @spm_xcconfigs_dir ||= Dir.prepare(spm_sandbox / "xcconfigs")
    end

    def spm_cache_dir
      @spm_cache_dir ||= Dir.prepare(Pathname("~/.xccache/#{install_config}").expand_path)
    end

    def spm_binaries_dir
      @spm_binaries_dir ||= Dir.prepare(spm_sandbox / "binaries")
    end

    def spm_build_dir
      @spm_build_dir ||= spm_umbrella_sandbox / ".build"
    end

    def spm_artifacts_dir
      @spm_artifacts_dir ||= spm_build_dir / "artifacts"
    end

    def spm_proxy_sandbox
      @spm_proxy_sandbox ||= Dir.prepare(spm_sandbox / "proxy")
    end

    def spm_umbrella_sandbox
      @spm_umbrella_sandbox ||= Dir.prepare(spm_sandbox / "umbrella")
    end

    def spm_metadata_dir
      @spm_metadata_dir ||= Dir.prepare(spm_sandbox / "metadata")
    end

    def lockfile
      @lockfile ||= Lockfile.new(Pathname("xccache.lock").expand_path)
    end

    def cachemap
      require "xccache/cache/cachemap"
      @cachemap ||= Cache::Cachemap.new(sandbox / "cachemap.json")
    end

    def projects
      @projects ||= Pathname(".").glob("*.xcodeproj").map do |p|
        Xcodeproj::Project.open(p)
      end
    end

    def project_targets
      projects.flat_map(&:targets)
    end

    def remote_config
      pick_per_install_config(raw["remote"] || {})
    end

    def ignore_list
      raw["ignore"] || []
    end

    def ignore?(item)
      return true if ignore_local? && lockfile.local_pkg_slugs.include?(item.split("/").first)
      ignore_list.any? { |p| File.fnmatch(p, item) }
    end

    def ignore_local?
      raw["ignore_local"]
    end

    def ignore_build_errors?
      raw["ignore_build_errors"]
    end

    def keep_pkgs_in_project?
      raw["keep_pkgs_in_project"]
    end

    def default_sdk
      raw["default_sdk"] || "iphonesimulator"
    end

    private

    def pick_per_install_config(hash)
      hash[install_config] || hash["default"] || {}
    end
  end
end
