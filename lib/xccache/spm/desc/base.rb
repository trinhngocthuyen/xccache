require "xccache/core"

module XCCache
  module SPM
    class Package
      class BaseObject < JSONRepresentable
        include Config::Mixin

        attr_accessor :root, :retrieve_pkg_desc

        def name
          raw["name"]
        end

        def full_name
          is_a?(Description) ? name : "#{pkg_slug}/#{name}"
        end

        def to_s
          "<#{self.class} name=#{name}>"
        end

        def pkg_name
          @pkg_name ||= root.name
        end

        def pkg_slug
          @pkg_slug ||= root.path.basename(".json").to_s
        end

        def fetch(key, dtype)
          raw[key].map do |h|
            o = dtype.new(nil, raw: h)
            o.root = root
            o.retrieve_pkg_desc = retrieve_pkg_desc
            o
          end
        end

        def pkg_desc_of(name)
          retrieve_pkg_desc.call(name)
        end

        def src_dir
          @src_dir ||= begin
            path = raw.fetch("packageKind", {}).fetch("root", [])[0]
            Pathname.new(path) unless path.nil?
          end
        end
      end
    end
  end
end
