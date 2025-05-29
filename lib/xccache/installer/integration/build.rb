module XCCache
  class Installer
    module BuildIntegrationMixin
      def build(options = {})
        to_build = targets_to_build(options)
        return UI.warn("Detected no targets to build among cache-missed targets") if to_build.empty?

        UI.info("-> Targets to build: #{to_build.to_s.bold}")
        umbrella_pkg.build(**options, targets: to_build)
      end

      def targets_to_build(options)
        items = options[:targets] || []
        items = config.cachemap.missed.map { |x| File.basename(x) } if items.empty?
        targets = items.map { |x| umbrella_pkg.get_target(x) }

        if options[:recursive]
          UI.message("Will include cache-missed recursive targets")
          targets += targets.flat_map do |t|
            t.recursive_targets.select { |x| config.cachemap.missed?(x.full_name) }
          end
        end
        # TODO: Sort by number of dependents
        targets.map(&:full_name).uniq
      end
    end
  end
end
