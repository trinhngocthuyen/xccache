require "xccache/core/syntax/plist"

module XCCache
  module SPM
    class XCFramework
      class Metadata < PlistRepresentable
        class Library < Hash
          def id
            self["LibraryIdentifier"]
          end

          def platform
            self["SupportedPlatform"]
          end

          def archs
            self["SupportedArchitectures"]
          end

          def simulator?
            self["SupportedPlatformVariant"] == "simulator"
          end

          def triples
            @triples ||= archs.map do |arch|
              simulator? ? "#{arch}-#{platform}-simulator" : "#{arch}-#{platform}"
            end
          end
        end

        def available_libraries
          @available_libraries ||= raw.fetch("AvailableLibraries", []).map { |h| Library.new.merge(h) }
        end

        def triples
          @triples ||= available_libraries.flat_map(&:triples)
        end
      end
    end
  end
end
