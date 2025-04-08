require "xccache/spm/pkg"
Dir["#{__dir__}/installer/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    include PkgMixin

    def initialize(*args, **kwargs); end

    def sync_lockfile
      UI.message("Syncing lockfile")
      update_projects do |project|
        lockfile.merge!(project.display_name => lockfile_hash_for_project(project))
      end
      lockfile.save
    end

    def lockfile
      config.lockfile
    end

    def cachemap
      config.cachemap
    end

    def projects
      config.projects
    end

    def save_projects
      yield if block_given?
      projects.each(&:save)
    end

    def update_projects
      projects.each do |project|
        yield project if block_given?
        project.save
      end
    end

    private

    def lockfile_hash_for_project(project)
      deps_by_targets = project.targets.to_h do |target|
        deps = target.non_xccache_pkg_product_dependencies.map { |d| "#{d.pkg.slug}/#{d.product_name}" }
        [target.name, deps]
      end
      {
        "packages" => project.non_xccache_pkgs.map(&:to_h),
        "dependencies" => deps_by_targets,
      }
    end
  end
end
