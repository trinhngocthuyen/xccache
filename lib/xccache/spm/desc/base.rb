require "xccache/core/json"
require "xccache/core/config"

module XCCache
  module SPM
    class Package
      class BaseObject < JSONRepresentable
        include Config::Mixin

        def name
          raw["name"]
        end
      end
    end
  end
end
