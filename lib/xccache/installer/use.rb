require "xccache/installer/pkg/binaries"

module XCCache
  class Installer
    class Use < Installer
      def install!
        sync_lockfile
        binaries_pkg.prepare
        update_projects do |project|
          replace_binaries_for_project(project)
        end
      end

      private

      def binaries_pkg
        @binaries_pkg ||= BinariesPkg.new(
          path: Dir.prepare(config.spm_binaries_sandbox),
          projects: projects,
          cachemap: cachemap,
        )
      end

      def replace_binaries_for_project(project)
        project.targets.each do |target|
          target.add_xccache_product_dependency unless target.has_xccache_product_dependency?
          target.remove_pkg_product_dependencies { |d| cachemap.hit?(d.full_name) }
        end
      end
    end
  end
end
