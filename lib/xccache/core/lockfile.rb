require "xccache/core/json"

module XCCache
  class Lockfile < JSONRepresentable
    def hash_for_project(project)
      raw[project.display_name] || {}
    end

    def merge!(hash)
      raw.deep_merge!(hash)
    end
  end
end
