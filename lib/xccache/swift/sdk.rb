require "xccache/core/sh"

module XCCache
  module Swift
    class Sdk
      attr_reader :name

      NAME_TO_TRIPLE = {
        :iphonesimulator => "arm64-apple-ios-simulator",
        :iphoneos => "arm64-apple-ios",
      }.freeze

      def initialize(name)
        @name = name
      end

      def to_s
        name
      end

      def triple
        NAME_TO_TRIPLE[name.to_sym]
      end

      def sdk_path
        @sdk_path ||= Pathname(Sh.capture_output("xcrun --sdk #{name} --show-sdk-path")).realpath
      end
    end
  end
end
