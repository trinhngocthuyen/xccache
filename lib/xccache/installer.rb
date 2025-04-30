require "xccache/spm"
Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    include PkgMixin

    def initialize(options = {})
      @umbrella_pkg = options[:umbrella_pkg]
      @skip_resolving_dependencies = options[:skip_resolving_dependencies]
    end

    def perform_install
      verify_projects!
      sync_lockfile if @umbrella_pkg.nil?
      umbrella_pkg.prepare(skip_resolve: @skip_resolving_dependencies) if @umbrella_pkg.nil?
      yield
      umbrella_pkg.write_manifest
      umbrella_pkg.gen_cachemap_viz
      add_xccache_refs_to_projects
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

    def add_xccache_refs_to_projects
      projects.each do |project|
        group = project["xccache.config"] || project.new_group("xccache.config")
        add_file = proc { |p| group[p.basename.to_s] || group.new_file(p) }
        add_file.call(config.spm_umbrella_sandbox / "Package.swift")
        add_file.call(config.lockfile.path)
        add_file.call(config.path) if config.path.exist?
      end
    end
  end
end
