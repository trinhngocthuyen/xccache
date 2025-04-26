require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Dependency < BaseObject
        def display_name
          slug
        end

        def local?
          raw.key?("fileSystem")
        end

        def hash
          @hash ||= local? ? raw["fileSystem"].first : raw["sourceControl"].first
        end

        def slug
          @slug ||=
            if hash.key?("path")
              File.basename(hash["path"])
            elsif (location = hash["location"]) && location.key?("remote")
              File.basename(location["remote"].flat_map(&:values)[0], ".*")
            else
              hash["identity"]
            end
        end

        def path
          @path ||= Pathname(hash["path"]).expand_path if local?
        end

        def pkg_desc
          @pkg_desc ||= pkg_desc_of(slug)
        end
      end
    end
  end
end
