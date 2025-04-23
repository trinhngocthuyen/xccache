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

      def targets_data
        raw["targets"] ||= {}
      end

      def missed
        get_cache_data(:missed)
      end

      def print_stats
        hit = get_cache_data(:hit)
        missed = get_cache_data(:missed)
        ignored = get_cache_data(:ignored)
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
