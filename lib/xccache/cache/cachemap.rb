require "xccache/core"

module XCCache
  module Cache
    class Cachemap < JSONRepresentable
      def depgraph_data
        raw["depgraph"] ||= {}
      end

      def cache_data
        raw["cache"] ||= {}
      end

      def manifest_data
        raw["manifest"] ||= { "targets" => {}, "deps" => {} }
      end

      def missed?(name)
        missed.include?(name)
      end

      def missed
        get_cache_data(:missed)
      end

      def stats
        %i[hit missed ignored].to_h do |type|
          count, total_count = get_cache_data(type).count, cache_data.count
          percent = total_count.positive? ? count * 100 / total_count : 0
          [type, "#{percent}% (#{count}/#{total_count})"]
        end
      end

      def print_stats
        hit, missed, ignored = %i[hit missed ignore].map { |type| get_cache_data(type) }
        total_count = cache_data.count
        UI.message <<~DESC
          -------------------------------------------------------------------
          Cache stats
          • Hit (#{hit.count}/#{total_count}): #{hit.to_s.green.dark}
          • Missed (#{missed.count}/#{total_count}): #{missed.to_s.yellow.dark}
          • Ignored (#{ignored.count}/#{total_count}): #{ignored.to_s.yellow.dark}
          -------------------------------------------------------------------
        DESC
      end

      def get_cache_data(type)
        cache_data.select { |_, v| v == type }.keys
      end
    end
  end
end
