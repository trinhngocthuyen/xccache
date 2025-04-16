require "xccache/core/syntax/json"

module XCCache
  class Lockfile < JSONRepresentable
    def hash_for_project(project)
      raw[project.display_name] ||= {}
    end

    def product_dependencies_by_targets
      @product_dependencies_by_targets ||= raw.values.map { |h| h["dependencies"] }.reduce { |acc, h| acc.merge(h) }
    end

    def deep_merge!(hash)
      raw.deep_merge!(hash)
    end

    def product_dependencies
      @product_dependencies ||= product_dependencies_by_targets.values.flatten.uniq
    end

    def targets_data
      @targets_data ||= product_dependencies_by_targets.transform_keys { |k| "#{k}.xccache" }
    end
  end
end
