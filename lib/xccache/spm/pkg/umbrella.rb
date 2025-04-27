require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"
require "xccache/spm/pkg/base"

Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  module SPM
    class Package
      class Umbrella < Package
        include Config::Mixin
        include UmbrellaCachemapMixin
        include UmbrellaDescsMixin
        include UmbrellaBuilldMixin
        include UmbrellaManifestMixin
        include UmbrellaVizMixin

        def initialize(options = {})
          super
          @descs = []
          @descs_by_name = {}
          @dependency_targets_by_products = {}
        end

        def prepare
          create
          resolve
          sync_cachemap
          gen_cachemap_viz
        end

        def resolve
          super
          create_symlinks
          gen_metadata
          resolve_recursive_dependencies
          create_symlinks_to_artifacts
        end

        def resolve_recursive_dependencies
          UI.section("Resolving recursive dependencies")
          @descs.each do |desc|
            @dependency_targets_by_products.merge!(desc.resolve_recursive_dependencies.transform_keys(&:full_name))
          end
        end

        def create
          UI.info("Creating umbrella package")
          # Initially, write json with the original data in lockfile (without cache)
          write_manifest(no_cache: true)
          # Create dummy sources dirs prefixed with `.` so that they do not show up in Xcode
          config.project_targets.each do |target|
            dir = Dir.prepare(root_dir / ".Sources" / "#{target.name}.xccache")
            (dir / "dummy.swift").write("")
          end
        end

        def create_symlinks
          # Symlinks for convenience
          (root_dir / "binaries").symlink_to(root_dir.parent / "binaries")
          (root_dir / ".build").symlink_to(root_dir.parent / ".build")
          (root_dir / ".build/checkouts").symlink_to(root_dir.parent / "checkouts")
        end

        def create_symlinks_to_artifacts
          # Clean up broken symlinks
          config.spm_binaries_frameworks_dir.glob("*/*.xcframework").each do |p|
            p.rmtree if p.symlink? && !p.readlink.exist?
          end

          UI.message("Creating symlinks to binary artifacts of targets: #{binary_targets.map(&:full_name).to_s.dark}")
          binary_targets.each do |target|
            dst_path = config.spm_binaries_frameworks_dir / target.name / "#{target.name}.xcframework"
            # For local xcframework, just symlink to the path
            # Zip frameworks (either of local or remote pkgs) are unzipped in the build artifacts
            target.local_binary_path.symlink_to(dst_path) if target.local_binary_path&.extname == ".xcframework"
            config.spm_artifacts_dir.glob("#{target.full_name}/*.xcframework").each do |p|
              p.symlink_to(dst_path)
            end
          end
        end
      end
    end
  end
end
