module XCCache
  class Framework
    class XCFramework
      attr_reader :name, :module_name, :pkg_dir, :pkg_desc, :config, :sdks, :path

      def initialize(options = {})
        @name = options[:name]
        @module_name = @name.c99extidentifier
        @pkg_dir = options[:pkg_dir]
        @pkg_desc = options[:pkg_desc]
        @config = options[:config]
        @sdks = options[:sdks]
        @path = options[:path]
        raise GeneralError, "Missing sdks for xcframework: #{name}" if @sdks.empty?
      end

      def create(merge_slices: false)
        tmp_new_path = tmpdir / "new.xcframework"
        tmp_existing_path = tmpdir / "existing.framework"

        slices.each(&:build)
        UI.section("Creating #{name}.xcframework from slices") do
          create_xcframework(from: slices.map(&:path), to: tmp_new_path)
        end

        path.copy(to: tmp_existing_path) if path.exist? && merge_slices
        path.rmtree if path.exist?

        if merge_slices && tmp_existing_path.exist?
          UI.section("Merging #{name}.xcframework with existing slices") do
            framework_paths =
              [tmp_new_path, tmp_existing_path]
              .flat_map { |p| p.glob("*/*.framework") }
              .uniq { |p| p.parent.basename.to_s } # uniq by id (ex. ios-arm64), preferred new ones
            create_xcframework(from: framework_paths, to: path)
          end
        else
          path.parent.mkpath
          tmp_new_path.copy(to: path)
        end
        tmpdir.rmtree
      end

      def tmpdir
        @tmpdir ||= Dir.create_tmpdir
      end

      def slices
        @slices ||= sdks.map do |sdk|
          Framework::Slice.new(
            name: name,
            pkg_dir: pkg_dir,
            pkg_desc: pkg_desc,
            sdk: sdk,
            config: config,
            path: Dir.prepare(tmpdir / sdk.triple / "#{module_name}.framework"),
            tmpdir: tmpdir,
          )
        end
      end

      def create_xcframework(options = {})
        cmd = ["xcodebuild", "-create-xcframework"]
        cmd << "-output" << options[:to]
        options[:from].each { |p| cmd << "-framework" << p }
        cmd << "> /dev/null" # Only care about errors
        Sh.run(cmd)
      end
    end
  end
end
