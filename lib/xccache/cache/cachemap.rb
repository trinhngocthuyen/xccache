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
        verbose = Config.instance.verbose?
        colors = { :hit => "green", :missed => "yellow" }
        descs = %i[hit missed ignored].to_h do |type|
          colorize = proc { |s| colors.key?(type) ? s.send(colors[type]).dark : s.dark }
          items = get_cache_data(type)
          percent = cache_data.count.positive? ? items.count.to_f / cache_data.count * 100 : 0
          desc = "#{type} #{percent.round}% (#{items.count}/#{cache_data.count})"
          desc = "#{desc} #{colorize.call(items.to_s)}" if verbose && !items.empty?
          [type, desc]
        end
        if verbose
          UI.info <<~DESC
            -------------------------------------------------------------------
            Cache stats
            #{descs.values.map { |s| "• #{s.capitalize}" }.join("\n")}
            -------------------------------------------------------------------
          DESC
        else
          UI.info <<~DESC
            -------------------------------------------------------------------
            Cache stats: #{descs.values.join(', ')}
            To see the full stats, use --verbose in the xccache command
            -------------------------------------------------------------------
          DESC
        end
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
