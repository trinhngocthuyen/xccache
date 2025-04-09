module XCCache
  class Framework
    class Slice
      attr_reader :name, :pkg_dir, :sdk, :config, :path

      def initialize(options = {})
        @name = options[:name]
        @pkg_dir = Pathname(options[:pkg_dir] || ".").expand_path
        @sdk = options[:sdk]
        @config = options[:config] || "debug"
        @path = options[:path]
      end

      def build
        UI.section("Building slice: #{name} (#{config}, #{sdk})".bold) do
          cmd = ["swift", "build"] + swift_build_args
          cmd << "--package-path" << pkg_dir
          cmd << "--target" << name
          cmd << "--sdk" << sdk.sdk_path
          # Workaround for swiftinterface emission
          # https://github.com/swiftlang/swift/issues/64669#issuecomment-1535335601
          cmd << "-Xswiftc" << "-enable-library-evolution"
          cmd << "-Xswiftc" << "-alias-module-names-in-module-interface"
          cmd << "-Xswiftc" << "-emit-module-interface"
          Sh.run(cmd, suppress_err: /(dependency '.*' is not used by any target|unable to create symbolic link)/)
          create_framework
        end
      end

      def create_framework
        create_info_plist
        create_framework_binary
        copy_headers
        copy_swiftmodules
      end

      def create_framework_binary
        cmd = ["libtool", "-static"]
        cmd << "-o" << "#{path}/#{name}"
        cmd << "#{products_dir}/#{name}.build/*.o"
        Sh.run(cmd)
        FileUtils.chmod("+x", "#{path}/#{name}")
      end

      def create_info_plist
        (path / "Info.plist").write(info_plist_content)
      end

      def copy_headers
        Dir.prepare(path / "Headers")
      end

      def copy_swiftmodules
        swiftmodule_dir = Dir.prepare("#{path}/Modules/#{name}.swiftmodule")
        swiftinterfaces = products_dir.glob("#{name}.build/#{name}.swiftinterface")
        to_copy = products_dir.glob("Modules/#{name}.*") + swiftinterfaces
        to_copy.each do |p|
          FileUtils.copy_entry(p, swiftmodule_dir / p.basename.sub(name, sdk.triple))
        end
      end

      def products_dir
        @products_dir ||= pkg_dir / ".build" / sdk.triple / config
      end

      def swift_build_args
        [
          "--configuration", config,
          "--triple", sdk.triple,
        ]
      end

      def info_plist_content
        <<~HEREDOC
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>CFBundleIdentifier</key>
              <string>com.#{name}</string>
              <key>CFBundleName</key>
              <string>#{name}</string>
              <key>CFBundleExecutable</key>
              <string>#{name}</string>
              <key>CFBundleVersion</key>
              <string>1.0</string>
              <key>CFBundlePackageType</key>
              <string>FMWK</string>
          </dict>
          </plist>
        HEREDOC
      end
    end
  end
end
