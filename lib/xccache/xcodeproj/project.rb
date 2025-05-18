require "xcodeproj"

module Xcodeproj
  class Project
    Log = XCCache::UI

    def display_name
      relative_path.to_s
    end

    def relative_path
      @relative_path ||= path.relative_path_from(Pathname(".").expand_path)
    end

    def dir
      path.parent
    end

    def pkgs
      root_object.package_references
    end

    def xccache_pkg
      pkgs.find(&:xccache_pkg?)
    end

    def non_xccache_pkgs
      pkgs.reject(&:xccache_pkg?)
    end

    def has_pkg?(hash)
      pkg_hash = XCCache::Lockfile::Pkg.from_h(hash)
      pkgs.any? { |p| p.id == pkg_hash.id }
    end

    def has_xccache_pkg?
      pkgs.any?(&:xccache_pkg?)
    end

    def add_pkg(hash)
      pkg_hash = XCCache::Lockfile::Pkg.from_h(hash)
      pkg_hash["relative_path"] = pkg_hash.relative_path_from_dir(dir).to_s if pkg_hash.key == "path_from_root"

      Log.message("Add package #{pkg_hash.id.bold} to project #{display_name.bold}")
      cls = pkg_hash.local? ? XCLocalSwiftPackageReference : XCRemoteSwiftPackageReference
      ref = new(cls)
      custom_keys = ["path_from_root"]
      pkg_hash.each { |k, v| ref.send("#{k}=", v) unless custom_keys.include?(k) }
      root_object.package_references << ref
      ref
    end

    def add_xccache_pkg
      sandbox_path = XCCache::Config.instance.spm_umbrella_sandbox
      add_pkg("relative_path" => sandbox_path.relative_path_from(path.parent).to_s)
    end

    def remove_pkgs(&block)
      pkgs.select(&block).each do |pkg|
        XCCache::UI.info("(-) Remove #{pkg.display_name.red} from package refs of project #{display_name.bold}")
        pkg.remove_from_project
      end
    end

    def get_target(name)
      targets.find { |t| t.name == name }
    end

    def get_pkg(name)
      pkgs.find { |p| p.slug == name }
    end

    def xccache_config_group
      self["xccache.config"] || new_group("xccache.config")
    end
  end
end
