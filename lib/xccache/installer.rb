require "xccache/spm"
require "xccache/installer/integration"
Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    include PkgMixin
    include IntegrationMixin

    def initialize(options = {})
      ctx = options[:ctx]
      raise GeneralError, "Missing context (Command) for #{self.class}" if ctx.nil?
      @umbrella_pkg = options[:umbrella_pkg]
      @install_options = ctx.install_options
      @build_options = ctx.build_options
    end

    def perform_install
      verify_projects!
      projects.each { |project| migrate_umbrella_to_proxy(project) }
      UI.message("Using cache dir: #{config.spm_cache_dir}")
      config.ensure_file!
      config.in_installation = true
      sync_lockfile
      proxy_pkg.prepare(@install_options)

      yield if block_given?

      gen_supporting_files
      projects.each do |project|
        add_xccache_refs_to_project(project)
        inject_xcconfig_to_project(project)
      end
      gen_cachemap_viz
    end

    def sync_lockfile
      UI.info("Syncing lockfile")
      known_dependencies = lockfile.known_product_dependencies
      update_projects do |project|
        lockfile.deep_merge!(
          project.display_name => lockfile_hash_for_project(project, known_dependencies)
        )
      end
      lockfile.save
      lockfile.verify!
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

    def lockfile_hash_for_project(project, known_dependencies)
      deps_by_targets = project.targets.to_h do |target|
        deps = target.non_xccache_pkg_product_dependencies.map do |dep|
          next dep.full_name unless dep.pkg.nil?
          known = known_dependencies.find { |x| File.basename(x) == dep.product_name }
          UI.warn("-> Assuming #{known} for #{dep.full_name}".dark) if known
          known || dep.full_name
        end
        [target.name, deps.sort]
      end
      {
        "packages" => project.non_xccache_pkgs.map(&:to_h),
        "dependencies" => deps_by_targets,
        "platforms" => platforms_for_project(project),
      }
    end

    def platforms_for_project(project)
      project
        .targets.map { |t| [t.platform_name.to_s, t.deployment_target] }
        .sort.reverse.to_h # sort descendingly -> min value is picked for the hash
    end

    def verify_projects!
      raise "No projects detected. Are you running on the correct project directory?" if projects.empty?
    end

    def add_xccache_refs_to_project(project)
      group = project.xccache_config_group
      add_file = proc { |p| group[p.basename.to_s] || group.new_file(p) }
      add_file.call(config.spm_proxy_sandbox / "Package.swift")
      add_file.call(config.lockfile.path)
      add_file.call(config.path)
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

    def migrate_umbrella_to_proxy(project)
      return unless project.xccache_pkg&.slug == "umbrella"

      UI.info <<~DESC
        Migrating from umbrella to proxy for project #{project.display_name}
        You should notice changes in project files from xccache/package/umbrella -> xccache/package/proxy.
        Don't worry, this is expected.
      DESC
        .yellow

      project.xccache_pkg.relative_path = "xccache/packages/proxy"
      if (group = project.xccache_config_group) && (ref = group["Package.swift"])
        ref.path = "xccache/packages/proxy/Package.swift"
      end
    end
  end
end
