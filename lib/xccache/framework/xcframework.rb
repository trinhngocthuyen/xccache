module XCCache
  class Framework
    class XCFramework
      attr_reader :name, :config, :sdks, :path

      def initialize(name: nil, config: nil, sdks: [], path: nil)
        @name = name
        @config = config
        @sdks = sdks
        @path = path
      end

      def create
        slices.each(&:build)
        UI.message "Creating #{name}.xcframework from slices..."
        path.rmtree if path.exist?

        cmd = ["xcodebuild", "-create-xcframework"]
        cmd << "-output" << path
        slices.each { |slice| cmd << "-framework" << slice.path }
        Sh.run(cmd)
      ensure
        tmpdir.rmtree
      end

      def tmpdir
        @tmpdir ||= Pathname(Dir.mktmpdir("xccache"))
      end

      def slices
        @slices ||= sdks.map do |s|
          sdk = Swift::Sdk.new(s)
          Framework::Slice.new(
            name: name,
            sdk: sdk,
            config: config,
            path: Dir.prepare(tmpdir / sdk.triple / "#{name}.framework"),
          )
        end
      end
    end
  end
end
