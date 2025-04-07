require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      module PkgRefMixin
        def id
          local? ? (relative_path || path) : repositoryURL
        end

        def slug
          File.basename(id, File.extname(id))
        end

        def local?
          is_a?(XCLocalSwiftPackageReference)
        end

        def xccache_pkg?
          local? && id == "xccache/packages/binaries"
        end
      end

      class XCLocalSwiftPackageReference
        include PkgRefMixin

        def to_h
          { "relative_path" => relative_path, "path" => path }
        end
      end

      class XCRemoteSwiftPackageReference
        include PkgRefMixin

        def to_h
          { "repositoryURL" => repositoryURL, "requirement" => requirement }
        end
      end
    end
  end
end
