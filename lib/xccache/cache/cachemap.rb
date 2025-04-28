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

      def missed
        get_cache_data(:missed)
      end

      def stats
        describe = proc do |type|
          count = get_cache_data(type).count
          total_count = [cache_data.count, 1].max
          percent = (count * 100 / total_count).to_i
          "#{percent}% (#{count}/#{total_count})"
        end
        {
          :hit => describe.call(:hit),
          :missed => describe.call(:missed),
          :ignored => describe.call(:ignored),
        }
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
        cache_data.select { |k, v| !k.end_with?(".xccache") && v == type }.keys
      end
    end
  end
end
