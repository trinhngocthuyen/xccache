require "xccache/core/sh"

module XCCache
  module Swift
    class Sdk
      attr_reader :name

      NAME_TO_TRIPLE = {
        :iphonesimulator => "arm64-apple-ios-simulator",
        :iphoneos => "arm64-apple-ios",
        :macosx => "arm64-apple-macosx",
      }.freeze

      def initialize(name)
        @name = name
      end

      def to_s
        name
      end

      def triple(without_vendor: false)
        res = NAME_TO_TRIPLE[name.to_sym]
        res = res.sub("-apple", "") if without_vendor
        res
      end

      def sdk_path
        # rubocop:disable Layout/LineLength
        # /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
        # rubocop:enable Layout/LineLength
        @sdk_path ||= Pathname(Sh.capture_output("xcrun --sdk #{name} --show-sdk-path")).realpath
      end

      def sdk_platform_developer_path
        @sdk_platform_developer_path ||= sdk_path.parent.parent # iPhoneSimulator.platform/Developer
      end

      def swiftc_args
        developer_library_frameworks_path = sdk_platform_developer_path / "Library" / "Frameworks"
        developer_usr_lib_path = sdk_platform_developer_path / "usr" / "lib"
        [
          "-F#{developer_library_frameworks_path}",
          "-I#{developer_usr_lib_path}",
        ]
      end
    end
  end
end
