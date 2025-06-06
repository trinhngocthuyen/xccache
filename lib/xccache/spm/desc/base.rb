require "xccache/core"

module XCCache
  module SPM
    class Package
      class BaseObject < JSONRepresentable
        include Config::Mixin

        ATTRS = %i[root retrieve_pkg_desc].freeze
        attr_accessor(*ATTRS)

        def name
          raw["name"]
        end

        def full_name
          is_a?(Description) ? name : "#{pkg_slug}/#{name}"
        end

        def inspect
          to_s
        end

        def display_name
          name
        end

        def to_s
          "<#{self.class} name=#{display_name}>"
        end

        def cast_to(cls)
          o = cls.new(path, raw: raw)
          ATTRS.each { |sym| o.send("#{sym}=", send(sym.to_s)) }
          o
        end

        def pkg_name
          @pkg_name ||= root.name
        end

        def pkg_slug
          @pkg_slug ||= src_dir.basename.to_s
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
          @src_dir ||= Pathname(root.raw["path"]).parent
        end
      end
    end
  end
end
