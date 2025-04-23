require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Product < BaseObject
        include Cacheable
        cacheable :recursive_targets

        def target_names
          raw["targets"]
        end

        def flatten_as_targets
          targets
        end

        def targets
          @targets ||= root.targets.select { |t| target_names.include?(t.name) }
        end

        def library?
          type == :library
        end

        def type
          @type ||= raw["type"].keys.first.to_sym
        end

        def recursive_targets(platform: nil)
          targets + targets.flat_map { |t| t.recursive_targets(platform: platform) }.uniq
        end
      end
    end
  end
end
