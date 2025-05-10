require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class PBXFileSystemSynchronizedRootGroup
        attribute :name, String

        def display_name
          return name if name
          return File.basename(path) if path
          super
        end
      end
    end
  end
end
