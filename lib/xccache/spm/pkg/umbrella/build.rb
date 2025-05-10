module XCCache
  module SPM
    class Package
      module UmbrellaBuildMixin
        def build(options = {})
          to_build = targets_to_build(options)
          return UI.warn("Detected no targets to build among cache-missed targets") if to_build.empty?

          UI.info("-> Targets to build: #{to_build.to_s.bold}")
          super(options.merge(:targets => to_build))
          sync_cachemap(sdks: options[:sdks])
        end

        def targets_to_build(options)
          items = options[:targets] || []
          items = config.cachemap.missed.map { |x| File.basename(x) } if items.empty?
          targets = @descs.flat_map(&:targets).select { |t| items.include?(t.name) }
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
end
