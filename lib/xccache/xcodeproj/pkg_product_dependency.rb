require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class XCSwiftPackageProductDependency
        def full_name
          "#{pkg.slug}/#{product_name}"
        end

        def pkg
          package unless package.nil?
        end
      end
    end
  end
end
