require "xccache/spm"
Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    include PkgMixin

    def initialize(options = {})
      ctx = options[:ctx]
      raise GeneralError, "Missing context (Command) for #{self.class}" if ctx.nil?
      @umbrella_pkg = options[:umbrella_pkg]
      @install_options = ctx.install_options
      @build_options = ctx.build_options
    end

    def perform_install
      UI.message("Using cache dir: #{config.spm_cache_dir}")
      config.in_installation = true
      verify_projects!
      if @umbrella_pkg.nil?
        sync_lockfile
        umbrella_pkg.prepare(**@install_options)
      end

      yield
      umbrella_pkg.write_manifest
      umbrella_pkg.gen_xcconfigs
      projects.each do |project|
        add_xccache_refs_to_project(project)
        inject_xcconfig_to_project(project)
      end
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
        deps = target.non_xccache_pkg_product_dependencies.select(&:pkg).map { |d| "#{d.pkg.slug}/#{d.product_name}" }
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

    def add_xccache_refs_to_project(project)
      group = project.xccache_config_group
      add_file = proc { |p| group[p.basename.to_s] || group.new_file(p) }
      add_file.call(config.spm_umbrella_sandbox / "Package.swift")
      add_file.call(config.lockfile.path)
      add_file.call(config.path) if config.path.exist?
      group.ensure_synced_group(name: "local-packages", path: config.spm_local_pkgs_dir)
    end

    def inject_xcconfig_to_project(project)
      group = project.xccache_config_group.ensure_synced_group(name: "xcconfigs", path: config.spm_xcconfig_dir)
      project.targets.each do |target|
        xcconfig_path = config.spm_xcconfig_dir / "#{target.name}.xcconfig"
        target.build_configurations.each do |build_config|
          if (existing = build_config.base_configuration_xcconfig)
            next if existing.path == xcconfig_path

            relative_path = xcconfig_path.relative_path_from(existing.path.parent)
            next if existing.includes.include?(relative_path.to_s)

            UI.info("Injecting base configuration for #{target} (#{build_config}) (at: #{existing.path})")
            existing.path.write <<~DESC
              #include "#{relative_path}" // Injected by xccache, for prebuilt macros support
              #{existing.path.read.strip}
            DESC
          else
            UI.info("Setting base configuration #{target} (#{build_config}) as #{xcconfig_path}")
            build_config.base_configuration_reference_anchor = group
            build_config.base_configuration_reference_relative_path = xcconfig_path.basename.to_s
          end
        end
      end
    end
  end
end
