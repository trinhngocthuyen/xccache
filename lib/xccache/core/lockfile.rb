require "xccache/core/json"

module XCCache
  class Lockfile < JSONRepresentable
    def pkgs_by_projects
      raw["packages"]
    end

    def dependencies_by_projects
      raw["dependencies"]
    end

    def merge!(hash)
      raw.deep_merge!(hash)
    end
  end
end
