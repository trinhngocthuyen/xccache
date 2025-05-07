require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        def synced_groups
          children.grep(PBXFileSystemSynchronizedRootGroup)
        end

        def new_synced_group(options = {})
          synced_group = project.new(PBXFileSystemSynchronizedRootGroup)
          synced_group.path = options[:path].to_s
          synced_group.name = options[:name] || options[:path].basename.to_s
          self << synced_group
          synced_group
        end
      end
    end
  end
end
