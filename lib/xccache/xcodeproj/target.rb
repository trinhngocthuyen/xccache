require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class PBXNativeTarget
        def non_xccache_pkg_product_dependencies
          package_product_dependencies.reject { |d| d.pkg.xccache_pkg? }
        end
      end
    end
  end
end
