require "xccache/utils/template"

module XCCache
  class Framework
    class Slice
      attr_reader :name, :pkg_dir, :pkg_desc, :sdk, :config, :path, :tmpdir

      def initialize(options = {})
        @name = options[:name]
        @pkg_dir = Pathname(options[:pkg_dir] || ".").expand_path
        @pkg_desc = options[:pkg_desc]
        @sdk = options[:sdk]
        @config = options[:config] || "debug"
        @path = options[:path]
        @tmpdir = options[:tmpdir]
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
        create_headers
        create_modules
      end

      def create_framework_binary
        # Write .o file list into a file
        objlist_path = tmpdir / "objects.txt"
        objlist_path.write(products_dir.glob("#{name}.build/**/*.o").map(&:to_s).join("\n"))

        cmd = ["libtool", "-static"]
        cmd << "-o" << "#{path}/#{name}"
        cmd << "-filelist" << objlist_path.to_s
        Sh.run(cmd)
        FileUtils.chmod("+x", path / name)
      end

      def create_info_plist
        Template.new("framework.info.plist").render(
          {
            :name => name,
          },
          save_to: path / "Info.plist",
        )
      end

      def create_headers
        Dir.prepare(path / "Headers")
        copy_headers if use_clang?
      end

      def create_modules
        Dir.prepare(path / "Modules")
        return copy_swiftmodules unless use_clang?

        UI.message("Creating framework modulemap")
        Template.new("framework.modulemap").render(
          { :name => name },
          save_to: path / "Modules" / "module.modulemap"
        )
      end

      private

      def copy_headers
        UI.message("Copying headers")
        framework_headers_path = path / "Headers"
        umbrella_header_content =
          pkg_target
          .header_paths
          .map { |p| p.copy(to_dir: framework_headers_path) }
          .map { |p| "#include \"#{p.basename}\"" }
          .join("\n")
        (framework_headers_path / "#{name}-umbrella.h").write(umbrella_header_content)
      end

      def copy_swiftmodules
        UI.message("Copying swiftmodules")
        swiftmodule_dir = Dir.prepare("#{path}/Modules/#{name}.swiftmodule")
        swiftinterfaces = products_dir.glob("#{name}.build/#{name}.swiftinterface")
        to_copy = products_dir.glob("Modules/#{name}.*") + swiftinterfaces
        to_copy.each do |p|
          p.copy(to: swiftmodule_dir / p.basename.sub(name, sdk.triple))
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

      def use_clang?
        pkg_target.use_clang?
      end

      def pkg_target
        @pkg_target ||= pkg_desc.get_target(name)
      end
    end
  end
end
