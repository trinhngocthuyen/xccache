require "xccache/core/json"

module XCCache
  class Lockfile < JSONRepresentable
    def hash_for_project(project)
      raw[project.display_name] || {}
    end

    def merge!(hash)
      raw.deep_merge!(hash)
    end

    def all_explicit_dependencies
      raw.values.flat_map { |h| h["dependencies"].values.flatten }
    end

    def implicit_dependency?(name)
      !all_explicit_dependencies.include?(name)
    end
  end
end
