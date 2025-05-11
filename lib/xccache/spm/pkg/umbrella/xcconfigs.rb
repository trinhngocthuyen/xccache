module XCCache
  module SPM
    class Package
      module UmbrellaXCConfigsMixin
        def gen_xcconfigs
          UI.section("Generating xcconfigs") do
            macros_config_by_targets.each do |target, hash|
              xcconfig_path = config.spm_xcconfig_dir / "#{target}.xcconfig"
              UI.message("XCConfig of target #{target} at: #{xcconfig_path}")
              Xcodeproj::Config.new(hash).save_as(xcconfig_path)
            end
          end
        end

        private

        def macros_config_by_targets
          config.cachemap.manifest_data["macros"].to_h do |target, macros|
            swift_flags = macros.map do |m|
              basename = File.basename(m, ".*")
              binary_path = config.spm_binaries_dir / basename / "#{basename}.macro"
              "-load-plugin-executable #{binary_path}##{basename}"
            end
            hash = { "OTHER_SWIFT_FLAGS" => "$(inherited) #{swift_flags.join(' ')}" }
            [File.basename(target, ".*"), hash]
          end
        end
      end
    end
  end
end
