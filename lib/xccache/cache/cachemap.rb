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

      def missed?(name)
        missed.include?(name)
      end

      def missed
        get_cache_data(:missed)
      end

      def stats
        %i[hit missed ignored].to_h do |type|
          count, total_count = get_cache_data(type).count, cache_data.count
          percent = total_count.positive? ? (count.to_f * 100 / total_count).round : 0
          [type, "#{percent}% (#{count}/#{total_count})"]
        end
      end

      def print_stats
        hit, missed, ignored = %i[hit missed ignored].map { |type| get_cache_data(type) }
        total_count = cache_data.count
        UI.message <<~DESC
          -------------------------------------------------------------------
          Cache stats
          • Hit (#{hit.count}/#{total_count}): #{hit.to_s.green.dark}
          • Missed (#{missed.count}/#{total_count}): #{missed.to_s.yellow.dark}
          • Ignored (#{ignored.count}/#{total_count}): #{ignored.to_s.dark}
          -------------------------------------------------------------------
        DESC
      end

      def get_cache_data(type)
        cache_data.select { |k, v| v == type && !k.end_with?(".xccache") }.keys
      end

      def update_from_graph(graph)
        cache_data = graph["cache"].to_h do |k, v|
          next [k, :hit] if v
          next [k, :ignored] if Config.instance.ignore?(k)
          [k, :missed]
        end

        deps = graph["deps"]
        edges = deps.flat_map { |k, xs| xs.map { |v| { :source => k, :target => v } } }
        nodes = deps.keys.map do |k|
          {
            :id => k,
            :cache => cache_data[k],
            :type => ("agg" if k.end_with?(".xccache")),
            :binary => graph["cache"][k],
          }
        end
        self.raw = {
          "cache" => cache_data,
          "depgraph" => { "nodes" => nodes, "edges" => edges },
        }
        save
        print_stats
      end
    end
  end
end
