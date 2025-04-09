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
        name.end_with?(".binary")
      end

      def miss?(name)
        !hit?(name)
      end

      def missed
        all_items.select { |x| miss?(x) }.map { |x| x.split("/")[-1] }
      end

      def commit(items)
        mark(missed: items)
        yield
        mark(hit: items)
      end

      def mark(options = {})
        hits, missed = options[:hit] || [], options[:missed] || []
        UI.message("Mark as missed: #{missed}".yellow.dark) unless missed.empty?
        UI.message("Mark as hit: #{hits}".green.dark) unless hits.empty?
        raw.each_value do |project_hash|
          project_hash.each do |name, deps|
            project_hash[name] = deps.map do |d|
              d_regular = d.sub(".binary", "")
              d_binary = "#{d_regular}.binary"
              next d_regular if missed.include?(d) || missed.include?(d_binary)
              next d_binary if hits.include?(d) || hits.include?(d_regular)
              d
            end
          end
        end
        save
      end
    end
  end
end
