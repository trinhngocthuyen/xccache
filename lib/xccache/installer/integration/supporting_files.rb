module XCCache
  class Installer
    module SupportingFilesIntegrationMixin
      def gen_supporting_files
        UI.section("Generating supporting files") do
          gen_xcconfigs
        end
      end

      private

      def gen_xcconfigs
        macros_config_by_targets.each do |target, hash|
          xcconfig_path = config.spm_xcconfigs_dir / "#{target}.xcconfig"
          UI.message("XCConfig of target #{target} at: #{xcconfig_path}")
          Xcodeproj::Config.new(hash).save_as(xcconfig_path)
        end
      end

      def macros_config_by_targets
        proxy_pkg.graph["macros"].to_h do |target, paths|
          swift_flags = paths.map { |p| "-load-plugin-executable #{p}##{File.basename(p, '.*')}" }
          hash = { "OTHER_SWIFT_FLAGS" => "$(inherited) #{swift_flags.join(' ')}" }
          [File.basename(target, ".*"), hash]
        end
      end
    end
  end
end
