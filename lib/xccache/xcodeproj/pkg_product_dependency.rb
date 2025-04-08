require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class XCSwiftPackageProductDependency
        def full_name
          "#{pkg.slug}/#{product_name}"
        end

        def pkg
          return package unless package.nil?

          Log.warn("Missing pkg for #{inspect}")
        end
      end
    end
  end
end
