require "xcodeproj"

module Xcodeproj
  class Project
    module Object
      class PBXGroup
        def synced_groups
          children.grep(PBXFileSystemSynchronizedRootGroup)
        end

        def ensure_synced_group(name: nil, path: nil)
          synced_groups.find { |g| g.name == name } || new_synced_group(name: name, path: path)
        end

        def new_synced_group(name: nil, path: nil)
          path = path.relative_path_from(project.dir) unless path.relative?
          synced_group = project.new(PBXFileSystemSynchronizedRootGroup)
          synced_group.path = path.to_s
          synced_group.name = name || path.basename.to_s
          self << synced_group
          synced_group
        end
      end
    end
  end
end
