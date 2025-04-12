require "json"
require "xccache/framework/slice"
require "xccache/framework/xcframework"
require "xccache/swift/sdk"

module XCCache
  module SPM
    class Package
      attr_reader :root_dir

      def initialize(options = {})
        @root_dir = Pathname(options[:root_dir] || ".").expand_path
      end

      def build(options = {})
        targets = options.delete(:targets) || []
        targets = targets.split(",") if targets.is_a?(String)
        raise GeneralError, "No targets were specified" if targets.empty?

        targets.map { |t| t.split("/")[-1] }.each do |t|
          UI.section("\n▶ Building target: #{t}".bold.magenta) do
            build_target(**options, target: t)
          end
        end
      end

      def build_target(target: nil, sdk: nil, config: nil, out_dir: nil)
        out_dir = Pathname(out_dir || ".")
        sdks = (sdk || "iphonesimulator").split(",")
        Framework::XCFramework.new(
          name: target,
          pkg_dir: root_dir,
          config: config,
          sdks: sdks,
          path: out_dir / "#{target}.xcframework",
          pkg_desc: pkg_desc_of_target(target),
        ).create
      end

      def resolve(force: false)
        return if @resolved && !force

        UI.message("Resolving package dependencies of package #{root_dir.basename.to_s.dark}")
        Sh.run("swift package resolve --package-path #{root_dir} 2>&1")
        @resolved = true
      end

      private

      def pkg_desc_of_target(name)
        # TODO: Refactor this resolution logic
        find_pkg_desc = proc do
          # The current package contains the given target
          return pkg_desc if pkg_desc.has_target?(name)

          UI.message(
            "#{name.yellow.dark} is not a direct target of package #{root_dir.basename.to_s.dark} " \
            "-> trigger from dependencies"
          )
          # Otherwise, it's inside one of the dependencies. Need to resolve then find it
          resolve
          # FIXME: Handle local packages
          root_dir.glob(".build/checkouts/*").each do |dir|
            desc = Description.in_dir(dir)
            return desc if desc.has_target?(name)
          end
          raise GeneralError, "Cannot find package with the given target #{name}"
        end

        @cache_pkg_desc_by_name ||= {}
        @cache_pkg_desc_by_name[name] = find_pkg_desc.call unless @cache_pkg_desc_by_name.key?(name)
        @cache_pkg_desc_by_name[name]
      end

      def pkg_desc
        @pkg_desc ||= Description.in_dir(root_dir)
      end
    end
  end
end
