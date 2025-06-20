require "xccache/utils/template"

module XCCache
  module SPM
    class FrameworkSlice < Buildable
      def build(_options = {})
        live_log.puts("Building #{name}.framework (#{config}, #{sdk})".cyan, sticky: true)
        swift_build
        create_framework
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
        live_log.info("Override resource_bundle_accessor")
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
          cmd << "-target" << sdk.triple(with_version: true) << "-isysroot" << sdk.sdk_path
          cmd << "-o" << obj_path.to_s
          cmd << "-c" << source_path
        else
          cmd = ["xcrun", "swiftc"]
          cmd << "-emit-library" << "-emit-object"
          cmd << "-module-name" << module_name
          cmd << "-target" << sdk.triple(with_version: true) << "-sdk" << sdk.sdk_path
          cmd << "-o" << obj_path.to_s
          cmd << source_path
        end
        sh(cmd)
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
        sh(cmd)
        FileUtils.chmod("+x", path / module_name)
      end

      def create_info_plist
        Template.new("framework.info.plist").render(
          { :module_name => module_name },
          save_to: path / "Info.plist",
        )
      end

      def create_headers
        copy_headers
      end

      def create_modules
        copy_swiftmodules unless use_clang?

        live_log.info("Creating framework modulemap")
        Template.new("framework.modulemap").render(
          { :module_name => module_name, :target => name },
          save_to: modules_dir / "module.modulemap"
        )
      end

      def copy_headers
        live_log.info("Copying headers")
        swift_header_paths = products_dir.glob("#{module_name}.build/*-Swift.h")
        paths = swift_header_paths + pkg_target.header_paths
        paths.each { |p| process_header(p) }

        umbrella_header_content = paths.map { |p| "#include <#{module_name}/#{p.basename}>" }.join("\n")
        (headers_dir / "#{name}-umbrella.h").write(umbrella_header_content)
      end

      def process_header(path)
        handle_angle_bracket_import = proc do |statement, header|
          next statement if header.include?("/")

          # NOTE: If importing a header with flat angle-bracket style (ex. `#import <foo.h>`)
          # The header `foo.h` may belong to a dependency's headers.
          # When packaging into xcframework, `#import <foo.h>` no longer works because `foo.h`
          # coz it's not visible within the framework's headers
          # -> We need to explicitly specify the module it belongs to, ex. `#import <foo/foo.h>`
          targets = [pkg_target] + pkg_target.recursive_targets
          target = targets.find { |t| t.header_paths.any? { |p| p.basename.to_s == header } }
          next statement if target.nil?

          corrected_statement = statement.sub("<#{header}>", "<#{target.module_name}/#{header}>")
          <<~CONTENT
            // -------------------------------------------------------------------------------------------------
            // NOTE: This import was corrected by xccache, from flat angle-bracket to nested angle-bracket style
            // Original: `#{statement}`
            #{corrected_statement}
            // -------------------------------------------------------------------------------------------------
          CONTENT
        end

        content = path.read.gsub(/^ *#import <(.+)>/) { |m| handle_angle_bracket_import.call(m, $1) }
        (headers_dir / path.basename).write(content)
      end

      def copy_swiftmodules
        live_log.info("Copying swiftmodules")
        swiftmodule_dir = Dir.prepare("#{modules_dir}/#{module_name}.swiftmodule")
        swiftinterfaces = products_dir.glob("#{module_name}.build/#{module_name}.swiftinterface")
        to_copy = products_dir.glob("Modules/#{module_name}.*") + swiftinterfaces
        to_copy.each do |p|
          p.copy(to: swiftmodule_dir / p.basename.sub(module_name, sdk.triple))
        end
      end

      def copy_resource_bundles
        resolve_resource_symlinks
        live_log.info("Copying resource bundle to framework: #{resource_bundle_product_path.basename}")
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

      def use_clang?
        pkg_target.use_clang?
      end

      def resource_bundle_product_path
        @resource_bundle_product_path ||= products_dir / pkg_target.resource_bundle_name
      end

      def headers_dir
        @headers_dir ||= Dir.prepare(path / "Headers")
      end

      def modules_dir
        @modules_dir ||= Dir.prepare(path / "Modules")
      end
    end
  end
end
