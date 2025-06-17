module XCCache
  module SPM
    class Buildable
      attr_reader :name, :module_name, :pkg_dir, :pkg_desc, :sdk, :sdks, :config, :path, :tmpdir, :library_evolution,
                  :live_log
      alias library_evolution? library_evolution

      def initialize(options = {})
        @name = options[:name]
        @module_name = @name.c99extidentifier
        @pkg_dir = Pathname(options[:pkg_dir] || ".").expand_path
        @pkg_desc = options[:pkg_desc]
        @ctx_desc = options[:ctx_desc] # Context desc, could be an umbrella or a standalone pkg
        @sdks = options[:sdks] || []
        @sdk = options[:sdk] || @sdks&.first
        @config = options[:config] || "debug"
        @path = options[:path]
        @tmpdir = options[:tmpdir]
        @library_evolution = options[:library_evolution]
        @sdks.each { |sdk| sdk.version = @ctx_desc.platforms[sdk.platform] } if @ctx_desc
        @live_log = options[:live_log]
      end

      def build(options = {})
        raise NotImplementedError
      end

      def swift_build(target: nil)
        cmd = ["swift", "build"] + swift_build_args
        cmd << "--package-path" << pkg_dir
        cmd << "--target" << (target || name)
        cmd << "--sdk" << sdk.sdk_path
        sdk.swiftc_args.each { |arg| cmd << "-Xswiftc" << arg }
        if library_evolution?
          # Workaround for swiftinterface emission
          # https://github.com/swiftlang/swift/issues/64669#issuecomment-1535335601
          cmd << "-Xswiftc" << "-enable-library-evolution"
          cmd << "-Xswiftc" << "-alias-module-names-in-module-interface"
          cmd << "-Xswiftc" << "-emit-module-interface"
          cmd << "-Xswiftc" << "-no-verify-emitted-module-interface"
        end
        sh(cmd)
      end

      def sh(cmd)
        Sh.run(cmd, live_log: live_log)
      end

      def swift_build_args
        [
          "--configuration", config,
          "--triple", sdk.triple(with_version: true),
        ]
      end

      def pkg_target
        @pkg_target ||= pkg_desc.get_target(name)
      end
    end
  end
end
