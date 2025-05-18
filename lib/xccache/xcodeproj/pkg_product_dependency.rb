require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class XCSwiftPackageProductDependency
        def full_name
          @full_name ||= "#{pkg&.slug || '__unknown__'}/#{product_name}"
        end

        def pkg
          return package if package
          return if @warned_missing_pkg
          @warned_missing_pkg = true
          XCCache::UI.warn("Missing pkg of product dependency #{uuid}: #{to_hash}")
        end

        def remove_alongside_related
          target = referrers.find { |x| x.is_a?(PBXNativeTarget) }
          XCCache::UI.info(
            "(-) Remove #{product_name.red} from product dependencies of target #{target.display_name.bold}"
          )
          target.dependencies.each { |x| x.remove_from_project if x.product_ref == self }
          target.build_phases.each do |phase|
            phase.files.select { |f| f.remove_from_project if f.product_ref == self }
          end
          remove_from_project
        end
      end
    end
  end
end
