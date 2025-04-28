module XCCache
  module SPM
    class Package
      module UmbrellaBuilldMixin
        def build(options = {})
          to_build = targets_to_build(options)
          return UI.warn("Detected no targets to build among cache-missed targets") if to_build.empty?

          UI.info("-> Targets to build: #{to_build.to_s.bold}")
          super(options.merge(:targets => to_build))
          sync_cachemap
        end

        def targets_to_build(options)
          items = options[:targets] || []
          items = config.cachemap.missed.map { |x| File.basename(x) } if items.empty?
          items.map do |name|
            target = @descs.flat_map(&:targets).find { |p| p.name == name }
            raise GeneralError, "Found no target: #{name}" if target.nil?
            target.full_name
          end
        end
      end
    end
  end
end
