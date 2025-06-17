require "xccache/spm/build"

module XCCache
  module SPM
    class XCFramework < Buildable
      attr_reader :slices

      def initialize(options = {})
        super
        @slices ||= @sdks.map do |sdk|
          FrameworkSlice.new(
            **options,
            sdks: [sdk],
            path: Dir.prepare(tmpdir / sdk.triple / "#{module_name}.framework"),
          )
        end
      end

      def build(merge_slices: false, **_options)
        tmp_new_path = tmpdir / "new.xcframework"
        tmp_existing_path = tmpdir / "existing.framework"

        slices.each(&:build)
        create_xcframework(from: slices.map(&:path), to: tmp_new_path)

        path.copy(to: tmp_existing_path) if path.exist? && merge_slices
        path.rmtree if path.exist?

        if merge_slices && tmp_existing_path.exist?
          framework_paths =
            [tmp_new_path, tmp_existing_path]
            .flat_map { |p| p.glob("*/*.framework") }
            .uniq { |p| p.parent.basename.to_s } # uniq by id (ex. ios-arm64), preferred new ones
          create_xcframework(from: framework_paths, to: path)
        else
          path.parent.mkpath
          tmp_new_path.copy(to: path)
        end
        live_log.info("-> XCFramework: #{path}")
      end

      def create_xcframework(options = {})
        live_log.info("Creating xcframework from slices")
        cmd = ["xcodebuild", "-create-xcframework"]
        cmd << "-allow-internal-distribution" unless library_evolution?
        cmd << "-output" << options[:to]
        options[:from].each { |p| cmd << "-framework" << p }
        cmd << "> /dev/null" # Only care about errors
        sh(cmd)
      end
    end
  end
end
