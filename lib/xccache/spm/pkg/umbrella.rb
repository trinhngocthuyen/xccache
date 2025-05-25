require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"
require "xccache/spm/pkg/base"
require "xccache/proxy"

Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  module SPM
    class Package
      class Umbrella < Package
        include Config::Mixin
        include ProxyMixin
        include UmbrellaCachemapMixin
        include UmbrellaDescsMixin
        include UmbrellaBuildMixin
        include UmbrellaVizMixin
        include UmbrellaXCConfigsMixin

        def initialize(options = {})
          super
          @descs = []
          @descs_by_name = {}
          @dependency_targets_by_products = {}
        end

        def prepare(options = {})
          create
          resolve unless options[:skip_resolving_dependencies]
          create_symlinks_to_local_pkgs
          gen_metadata
          resolve_recursive_dependencies
          create_symlinks_to_artifacts
          sync_cachemap(sdks: options[:sdks])
        end

        def resolve_recursive_dependencies
          UI.section("Resolving recursive dependencies")
          @descs.each do |desc|
            @dependency_targets_by_products.merge!(desc.resolve_recursive_dependencies.transform_keys(&:full_name))
          end
        end

        def create
          run_xccache_proxy("gen-umbrella")
        end

        def create_symlinks_to_local_pkgs
          pkg_desc.dependencies.select(&:local?).each do |dep|
            # For metadata generation
            dep.path.symlink_to(root_dir / ".build/checkouts/#{dep.slug}")
            # For convenience, synced group under `xccache.config` group in xcodeproj
            dep.path.symlink_to(Config.instance.spm_local_pkgs_dir / dep.slug)
          end
        end

        def create_symlinks_to_artifacts
          # Clean up symlinks beforehand
          config.spm_binaries_dir.glob("*/*.{xcframework,macro}").each do |p|
            p.rmtree if p.symlink?
          end

          binary_targets.each do |target|
            dst_path = config.spm_binaries_dir / target.name / "#{target.name}.xcframework"
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
