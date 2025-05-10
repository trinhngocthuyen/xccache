require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class XCBuildConfiguration
        def base_configuration_xcconfig
          path = base_configuration_xcconfig_path
          Config.new(path) if path
        end

        def base_configuration_xcconfig_path
          return base_configuration_reference.real_path if base_configuration_reference
          return unless base_configuration_reference_anchor && base_configuration_reference_relative_path
          project.dir / base_configuration_reference_anchor.path / base_configuration_reference_relative_path
        end
      end
    end
  end
end
