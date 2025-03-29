require "json"
require "tmpdir"
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
        targets = options.delete(:target) || regular_targets
        targets = [targets] if targets.is_a?(String)
        targets.each do |t|
          build_target(target: t, **options)
        end
      end

      def build_target(target: nil, sdk: nil, config: nil, out_dir: nil)
        out_dir = Pathname(out_dir || ".")
        sdks = (sdk || "iphonesimulator").split(",")
        Framework::XCFramework.new(
          name: target,
          config: config,
          sdks: sdks,
          path: out_dir / "#{target}.xcframework",
        ).create
      end

      def tmpdir
        @tmpdir ||= Pathname(Dir.mktmpdir("xccache"))
      end

      def regular_targets
        raw["targets"].select { |t| t["type"] == "regular" }.map { |t| t["name"] }
      end

      def raw
        return @raw unless @raw.nil?

        @raw = JSON.parse(Sh.capture_output("swift package dump-package"))
        @raw
      end
    end
  end
end
