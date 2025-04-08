require "xccache/spm"

module XCCache
  class Installer
    class Use < Installer
      def install!
        sync_lockfile
        binaries_pkg.prepare
        update_projects do |project|
          UI.section("Using cache for project #{project.display_name}".bold.green) do
            replace_binaries_for_project(project)
          end
        end
      end

      private

      def replace_binaries_for_project(project)
        project.add_xccache_pkg unless project.has_xccache_pkg?
        project.targets.each do |target|
          target.add_xccache_product_dependency unless target.has_xccache_product_dependency?
          target.remove_pkg_product_dependencies { |d| cachemap.hit?(d.full_name) }
        end
      end
    end
  end
end
