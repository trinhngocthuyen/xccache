require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Dependency < BaseObject
        def local?
          raw.key?("fileSystem")
        end

        def hash
          @hash ||= local? ? raw["fileSystem"].first : raw["sourceControl"].first
        end

        def slug
          @slug ||= hash["identity"]
        end

        def path
          @path ||= Pathname(hash["path"]).expand_path if local?
        end
      end
    end
  end
end
