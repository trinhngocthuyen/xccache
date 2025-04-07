require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class XCSwiftPackageProductDependency
        alias pkg package

        def full_name
          "#{pkg.slug}/#{product_name}"
        end
      end
    end
  end
end
