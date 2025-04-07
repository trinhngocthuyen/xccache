module XCCache
  class Installer
    class Rollback < Installer
      def install!
        update_projects do |project|
          rollback_for_project(project)
        end
      end

      private

      def rollback_for_project(project)
        UI.info("Rolling back cache for project #{project.display_name}...".bold.green)
        hash = lockfile.hash_for_project(project)
        pkgs, deps_by_targets = hash["packages"], hash["dependencies"]

        # Add packages back to the project
        pkgs.reject { |h| project.has_pkg?(h) }.each do |h|
          project.add_pkg(h)
        end

        # Add products back to `Link Binary with Libraries` of targets
        deps_by_targets.each do |name, deps|
          target = project.get_target(name)
          deps.reject { |d| target.has_pkg_product_dependency?(d) }.each do |d|
            target.add_pkg_product_dependency(d)
          end
        end

        # Remove .binary product from the project
        project.targets.each(&:remove_xccache_product_dependencies)
      end
    end
  end
end
