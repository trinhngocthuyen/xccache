require "xccache/utils/template"

module XCCache
  class Framework
    class Slice
      attr_reader :name, :module_name, :pkg_dir, :pkg_desc, :sdk, :config, :path, :tmpdir

      def initialize(options = {})
        @name = options[:name]
        @module_name = @name.c99extidentifier
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
          cmd << "-Xswiftc" << "-no-verify-emitted-module-interface"
          Sh.run(cmd, suppress_err: /(dependency '.*' is not used by any target|unable to create symbolic link)/)
          create_framework
        end
      end

      private

      def override_resource_bundle_accessor
        # By default, Swift generates resource_bundle_accessor.swift for targets having resources
        # (Check .build/<Target>.build/DerivedSources/resource_bundle_accessor.swift)
        # This enables accessing the resource bundle via `Bundle.module`.
        # However, `Bundle.module` expects the resource bundle to be under the app bundle,
        # which is not the case for binary targets. Instead the bundle is under `Frameworks/<Target>.framework`
        # WORKAROUND:
        # - Overriding resource_bundle_accessor.swift to add `Frameworks/<Target>.framework` to the search list
        # - Compiling this file into an `.o` file before using `libtool` to create the framework binary
        UI.message("Override resource_bundle_accessor")
        template_name = use_clang? ? "resource_bundle_accessor.m" : "resource_bundle_accessor.swift"
        source_path = tmpdir / File.basename(template_name)
        obj_path = products_dir / "#{module_name}.build" / "#{source_path.basename}.o"
        Template.new(template_name).render(
          { :pkg => pkg_target.pkg_name, :target => name, :module_name => module_name },
          save_to: source_path
        )

        if use_clang?
          cmd = ["xcrun", "clang"]
          cmd << "-x" << "objective-c"
          cmd << "-target" << sdk.triple << "-isysroot" << sdk.sdk_path
          cmd << "-o" << obj_path.to_s
          cmd << "-c" << source_path
        else
          cmd = ["xcrun", "swiftc"]
          cmd << "-emit-library" << "-emit-object"
          cmd << "-module-name" << module_name
          cmd << "-target" << sdk.triple << "-sdk" << sdk.sdk_path
          cmd << "-o" << obj_path.to_s
          cmd << source_path
        end
        Sh.run(cmd)
      end

      def create_framework
        override_resource_bundle_accessor if resource_bundle_product_path.exist?
        create_info_plist
        create_framework_binary
        create_headers
        create_modules
        copy_resource_bundles if resource_bundle_product_path.exist?
      end

      def create_framework_binary
        # Write .o file list into a file
        obj_paths = products_dir.glob("#{module_name}.build/**/*.o")
        raise GeneralError, "Detected no object files for #{name}" if obj_paths.empty?

        objlist_path = tmpdir / "objects.txt"
        objlist_path.write(obj_paths.map(&:to_s).join("\n"))

        cmd = ["libtool", "-static"]
        cmd << "-o" << "#{path}/#{module_name}"
        cmd << "-filelist" << objlist_path.to_s
        Sh.run(cmd)
        FileUtils.chmod("+x", path / module_name)
      end

      def create_info_plist
        Template.new("framework.info.plist").render(
          { :module_name => module_name },
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
          { :module_name => module_name },
          save_to: path / "Modules" / "module.modulemap"
        )
      end

      def copy_headers
        UI.message("Copying headers")
        framework_headers_path = path / "Headers"
        umbrella_header_content =
          pkg_target
          .header_paths
          .map { |p| p.copy(to_dir: framework_headers_path) }
          .map { |p| "#include <#{module_name}/#{p.basename}>" }
          .join("\n")
        (framework_headers_path / "#{module_name}-umbrella.h").write(umbrella_header_content)
      end

      def copy_swiftmodules
        UI.message("Copying swiftmodules")
        swiftmodule_dir = Dir.prepare("#{path}/Modules/#{module_name}.swiftmodule")
        swiftinterfaces = products_dir.glob("#{module_name}.build/#{module_name}.swiftinterface")
        to_copy = products_dir.glob("Modules/#{module_name}.*") + swiftinterfaces
        to_copy.each do |p|
          p.copy(to: swiftmodule_dir / p.basename.sub(module_name, sdk.triple))
        end
      end

      def copy_resource_bundles
        resolve_resource_symlinks
        UI.message("Copy resource bundle to framework: #{resource_bundle_product_path.basename}")
        resource_bundle_product_path.copy(to_dir: path)
      end

      def resolve_resource_symlinks
        # Well, Xcode seems to well handle symlinks in resources. In xcodebuild log, you would see something like:
        #   CpResource: builtin-copy ... -resolve-src-symlinks
        # But this is not the case if we build with `swift build`. Here, we have to manually handle it
        resource_bundle_product_path.glob("**/*").select(&:symlink?).reject(&:exist?).each do |p|
          UI.message("Resolve resource symlink: #{p}")
          original = pkg_target.resource_paths.find { |rp| rp.symlink? && rp.readlink == p.readlink }
          original&.realpath&.copy(to: p)
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

      def resource_bundle_product_path
        @resource_bundle_product_path ||= products_dir / pkg_target.bundle_name
      end
    end
  end
end
