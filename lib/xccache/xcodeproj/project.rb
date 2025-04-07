require "xcodeproj"

module Xcodeproj
  class Project
    def pkgs
      root_object.package_references
    end

    def non_xccache_pkgs
      pkgs.reject(&:xccache_pkg?)
    end

    def relative_path
      @relative_path ||= path.relative_path_from(Pathname(".").expand_path)
    end
  end
end
