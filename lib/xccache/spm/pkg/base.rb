require "json"
require "xccache/spm/xcframework/slice"
require "xccache/spm/xcframework/xcframework"
require "xccache/spm/xcframework/metadata"
require "xccache/swift/sdk"

module XCCache
  module SPM
    class Package
      include Cacheable
      cacheable :pkg_desc_of_target

      attr_reader :root_dir

      def initialize(options = {})
        @root_dir = Pathname(options[:root_dir] || ".").expand_path
        @warn_if_not_direct_target = options.fetch(:warn_if_not_direct_target, true)
      end

      def build(options = {})
        validate!
        targets = options.delete(:targets) || []
        raise GeneralError, "No targets were specified" if targets.empty?

        targets.map { |t| t.split("/")[-1] }.each_with_index do |t, i|
          UI.section("\n▶ Building target: #{t} (#{i + 1}/#{targets.count})".bold.magenta) do
            build_target(**options, target: t)
          rescue StandardError => e
            UI.error("Failed to build target: #{t}. Error: #{e}")
            raise e unless Config.instance.ignore_build_errors?
          end
        end
      end

      def build_target(target: nil, sdks: nil, config: nil, out_dir: nil, **options)
        target_pkg_desc = pkg_desc_of_target(target, skip_resolving_dependencies: options[:skip_resolving_dependencies])
        if target_pkg_desc.binary_targets.any? { |t| t.name == target }
          return UI.warn("Target #{target} is a binary target -> no need to build")
        end

        target = target_pkg_desc.get_target(target)

        out_dir = Pathname(out_dir || ".")
        out_dir /= target.name if options[:checksum]
        basename = options[:checksum] ? "#{target.name}-#{target.checksum}" : target.name
        basename += target.macro? ? ".macro" : ".xcframework"

        Dir.create_tmpdir do |_tmpdir|
          cls = target.macro? ? Macro : XCFramework
          cls.new(
            name: target.name,
            pkg_dir: root_dir,
            config: config,
            sdks: sdks,
            path: out_dir / basename,
            tmpdir: Dir.create_tmpdir,
            pkg_desc: target_pkg_desc,
            library_evolution: options[:library_evolution],
          ).build(**options)
        end
      end

      def resolve(force: false)
        return if @resolved && !force

        UI.section("Resolving package dependencies (package: #{root_dir.basename})", timing: true) do
          Sh.run("swift package resolve --package-path #{root_dir} 2>&1")
        end
        @resolved = true
      end

      private

      def validate!
        return unless root_dir.glob("Package*.swift").empty?
        raise GeneralError, "No Package.swift in #{root_dir}. Are you sure you're running on a package dir?"
      end

      def pkg_desc_of_target(name, skip_resolving_dependencies: false)
        # The current package contains the given target
        return pkg_desc if pkg_desc.has_target?(name)

        if @warn_if_not_direct_target
          UI.message(
            "#{name.yellow.dark} is not a direct target of package #{root_dir.basename.to_s.dark} " \
            "-> trigger from dependencies"
          )
        end
        # Otherwise, it's inside one of the dependencies. Need to resolve then find it
        resolve unless skip_resolving_dependencies

        @descs ||= if Config.instance.in_installation?
                   then Description.descs_in_metadata_dir[0]
                   else
                     Description.descs_in_dir(Pathname(".").expand_path)[0]
                   end
        desc = @descs.find { |d| d.has_target?(name) }
        return desc unless desc.nil?
        raise GeneralError, "Cannot find package with the given target #{name}"
      end

      def pkg_desc
        @pkg_desc ||= Description.in_dir(root_dir)
      end
    end
  end
end
