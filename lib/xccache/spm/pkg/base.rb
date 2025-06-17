require "json"
require "xccache/spm/xcframework/slice"
require "xccache/spm/xcframework/xcframework"
require "xccache/spm/xcframework/metadata"
require "xccache/spm/pkg/proxy"
require "xccache/swift/sdk"

module XCCache
  module SPM
    class Package
      include Config::Mixin
      include Proxy::Mixin

      include Cacheable
      cacheable :pkg_desc_of_target

      attr_reader :root_dir

      def initialize(options = {})
        @root_dir = Pathname(options[:root_dir] || ".").expand_path
      end

      def build(options = {})
        validate!
        targets = (options.delete(:targets) || []).map { |t| t.split("/")[-1] }
        raise GeneralError, "No targets were specified" if targets.empty?

        Dir.create_tmpdir do |tmpdir|
          targets.each_with_index do |t, i|
            target_tmpdir = Dir.prepare(tmpdir / t)
            log_dir = Dir.prepare(options[:log_dir] || target_tmpdir)
            live_log = LiveLog.new(tee: log_dir / "build_#{t}.log")
            live_log.capture("[#{i + 1}/#{targets.count}] Building target: #{t}") do
              build_target(**options, target: t, live_log: live_log, tmpdir: target_tmpdir)
            end
          rescue StandardError => e
            UI.error("Error: #{e}\n" + "For details, check out: #{live_log.tee}".yellow.bold)
            raise e unless Config.instance.ignore_build_errors?
          end
        end
      end

      def build_target(target: nil, sdks: nil, config: nil, out_dir: nil, **options)
        target_pkg_desc = pkg_desc_of_target(
          target,
          ensure_exist: true,
        )
        if target_pkg_desc.binary_targets.any? { |t| t.name == target }
          return UI.warn("Target #{target} is a binary target -> no need to build")
        end

        target = target_pkg_desc.get_target(target)

        out_dir = Pathname(out_dir || ".")
        out_dir /= target.name if options[:checksum]
        ext = target.macro? ? ".macro" : ".xcframework"
        basename = options[:checksum] ? "#{target.name}-#{target.checksum}" : target.name
        binary_path = out_dir / "#{basename}#{ext}"

        cls = target.macro? ? Macro : XCFramework
        cls.new(
          name: target.name,
          pkg_dir: root_dir,
          config: config,
          sdks: sdks,
          path: binary_path,
          tmpdir: options[:tmpdir],
          pkg_desc: target_pkg_desc,
          ctx_desc: pkg_desc || target_pkg_desc,
          library_evolution: options[:library_evolution],
          live_log: options[:live_log],
        ).build(**options)
        return if (symlinks_dir = options[:symlinks_dir]).nil?
        binary_path.symlink_to(symlinks_dir / target.name / "#{target.name}#{ext}")
      end

      def resolve
        return if @resolved
        xccache_proxy.run("resolve --pkg #{root_dir} --metadata #{metadata_dir}")
        @resolved = true
      end

      def pkg_desc
        descs_by_name[root_dir.basename.to_s]
      end

      def pkg_desc_of_target(name, **options)
        resolve
        desc = descs.find { |d| d.has_target?(name) }
        raise GeneralError, "Cannot find package with the given target #{name}" if options[:ensure_exist] && desc.nil?
        desc
      end

      def get_target(name)
        pkg_desc_of_target(name)&.get_target(name)
      end

      private

      def validate!
        return unless root_dir.glob("Package*.swift").empty?
        raise GeneralError, "No Package.swift in #{root_dir}. Are you sure you're running on a package dir?"
      end

      def metadata_dir
        config.in_installation? ? config.spm_metadata_dir : root_dir / ".build/metadata"
      end

      def descs
        @descs ||= load_descs[0]
      end

      def descs_by_name
        @descs_by_name ||= load_descs[1]
      end

      def load_descs
        @descs, @descs_by_name = Description.descs_in_metadata_dir(metadata_dir)
      end
    end
  end
end
