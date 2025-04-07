module XCCache
  module Swift
    module Swiftc
      def self.version
        @version ||= begin
          m = /Apple Swift version ([\d\.]+)/.match(Sh.capture_output("xcrun swift -version"))
          m.nil? ? "6.0" : m[1]
        end
      end

      def self.version_without_patch
        version.split(".")[...2].join(".")
      end
    end
  end
end
