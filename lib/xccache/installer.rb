require "xccache/spm"
Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    include PkgMixin

    def initialize(options = {})
      @umbrella_pkg = options[:umbrella_pkg]
    end

    def perform_install
      verify_projects!
      sync_lockfile if @umbrella_pkg.nil?
      umbrella_pkg.prepare if @umbrella_pkg.nil?
      yield
      umbrella_pkg.write_manifest
      umbrella_pkg.gen_cachemap_viz
    end

    def sync_lockfile
      UI.info("Syncing lockfile")
      update_projects do |project|
        lockfile.deep_merge!(project.display_name => lockfile_hash_for_project(project))
      end
      lockfile.save
    end

    def lockfile
      config.lockfile
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

    def verify_projects!
      raise "No projects detected. Are you running on the correct project directory?" if projects.empty?
    end
  end
end
