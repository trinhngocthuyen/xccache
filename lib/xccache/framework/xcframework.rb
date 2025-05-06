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

      def create
        slices.each(&:build)
        UI.section("Creating #{name}.xcframework from slices") do
          path.rmtree if path.exist?

          cmd = ["xcodebuild", "-create-xcframework"]
          cmd << "-output" << path
          slices.each { |slice| cmd << "-framework" << slice.path }
          Sh.run(cmd)
        end
        tmpdir.rmtree

        # TODO: Should we dispose tmpdir here as well?
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
    end
  end
end
