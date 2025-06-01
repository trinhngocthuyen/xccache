require_relative "build"

module XCCache
  module SPM
    class Macro < Buildable
      def initialize(options = {})
        super
        @library_evolution = false # swift-syntax is not compatible with library evolution
      end

      def build(_options = {})
        # NOTE: Building macro binary is tricky...
        # --------------------------------------------------------------------------------
        # Consider this manifest config: .target(Macro) -> .macro(MacroImpl)
        #   where `.target(Macro)` contains the interfaces
        #   and `.target(MacroImpl)` contains the implementation
        # --------------------------------------------------------------------------------
        # Building `.macro(MacroImpl)` does not produce the tool binary (MacroImpl-tool)... Only `.o` files.
        # Yet, linking those files are exhaustive due to many dependencies in swift-syntax
        # Luckily, building `.target(Macro)` does produce the tool binary.
        # -> WORKAROUND: Find the associated regular target and build it, then collect the tool binary
        # ---------------------------------------------------------------------------------
        associated_target = pkg_desc.targets.find { |t| t.direct_dependency_targets.include?(pkg_target) }
        UI.message(
          "#{name.yellow.dark} is a macro target. " \
          "Will build the associated target #{associated_target.name.dark} to get the tool binary."
        )
        swift_build(target: associated_target.name)
        binary_path = products_dir / "#{module_name}-tool"
        raise GeneralError, "Tool binary not exist at: #{binary_path}" unless binary_path.exist?
        binary_path.copy(to: path)
        FileUtils.chmod("+x", path)
        UI.info("-> Macro binary: #{path.to_s.dark}")
      end

      def products_dir
        @products_dir ||= pkg_dir / ".build" / "arm64-apple-macosx" / config
      end
    end
  end
end
