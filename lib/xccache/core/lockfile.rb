require "xccache/core/syntax/json"

module XCCache
  class Lockfile < JSONRepresentable
    class Pkg < Hash
      def self.from_h(h)
        Pkg.new.merge(h)
      end

      def key
        @key ||= ["repositoryURL", "path_from_root", "relative_path"].find { |x| key?(x) }
      end

      def id
        self[key]
      end

      def local?
        key != "repositoryURL"
      end

      def slug
        @slug ||= File.basename(id, ".*")
      end

      def relative_path_from_dir(dir)
        return id if key == "relative_path"
        (Pathname.pwd / id).relative_path_from(dir) if key == "path_from_root"
      end
    end

    def hash_for_project(project)
      raw[project.display_name] ||= {}
    end

    def product_dependencies_by_targets
      @product_dependencies_by_targets ||= raw.values.map { |h| h["dependencies"] }.reduce { |acc, h| acc.merge(h) }
    end

    def deep_merge!(hash)
      raw.deep_merge!(
        hash,
        uniq_block: proc { |h| h.is_a?(Hash) ? Pkg.from_h(h).id || h : h },
        sort_block: proc { |x| x.to_s.downcase },
      )
      # After deep_merge, clear property cache
      (instance_variables - %i[@path @raw]).each do |ivar|
        remove_instance_variable(ivar)
      end
    end

    def pkgs
      @pkgs ||= raw.values.flat_map { |h| h["packages"] || [] }.map { |h| Pkg.from_h(h) }
    end

    def local_pkgs
      @local_pkgs ||= pkgs.select(&:local?).uniq
    end

    def local_pkg_slugs
      @local_pkg_slugs ||= local_pkgs.map(&:slug).uniq
    end

    def known_product_dependencies
      raw.empty? ? [] : product_dependencies.reject { |d| File.dirname(d) == "__unknown__" }
    end

    def product_dependencies
      @product_dependencies ||= product_dependencies_by_targets.values.flatten.uniq
    end

    def targets_data
      @targets_data ||= product_dependencies_by_targets.transform_keys { |k| "#{k}.xccache" }
    end

    def verify!
      known_slugs = pkgs.map(&:slug)
      unknown = product_dependencies.reject { |d| known_slugs.include?(File.dirname(d)) }
      return if unknown.empty?

      UI.error! <<~DESC
        Unknown product dependencies at #{path}:

        #{unknown.sort.map { |d| "  • #{d}" }.join("\n")}

        Refer to this doc for how to resolve this issue:
          https://github.com/trinhngocthuyen/xccache/blob/main/docs/troubleshooting.md#unknown-product-dependencies
      DESC
    end
  end
end
