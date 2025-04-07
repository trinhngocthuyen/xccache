require "xccache/core/json"

module XCCache
  module Cache
    class Cachemap < JSONRepresentable
      def hash_for_project(project)
        raw[project.display_name] || {}
      end

      def all_items
        raw.values.flat_map { |h| h.values.flatten }
      end

      def hit?(name)
        all_items.include?(name)
      end
    end
  end
end
