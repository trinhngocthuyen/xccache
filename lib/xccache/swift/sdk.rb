require "xccache/core/sh"

module XCCache
  module Swift
    class Sdk
      attr_reader :name

      NAME_TO_TRIPLE = {
        :iphonesimulator => "arm64-apple-ios-simulator",
        :iphoneos => "arm64-apple-ios",
        :macos => "arm64-apple-macos",
        :watchos => "arm64-apple-watchos",
        :watchsimulator => "arm64-apple-watchos-simulator",
        :appletvos => "arm64-apple-tvos",
        :appletvsimulator => "arm64-apple-tvos-simulator",
        :xros => "arm64-apple-xros",
        :xrsimulator => "arm64-apple-xros-simulator",
      }.freeze

      def initialize(name)
        @name = name
        return if NAME_TO_TRIPLE.key?(name.to_sym)
        raise GeneralError, "Unknown sdk: #{name}. Must be one of #{NAME_TO_TRIPLE.keys}"
      end

      def to_s
        name
      end

      def triple(without_vendor: false)
        res = NAME_TO_TRIPLE[name.to_sym]
        res = res.sub("-apple", "") if without_vendor
        res
      end

      def sdk_name
        name == "macos" ? "macosx" : name
      end

      def sdk_path
        # rubocop:disable Layout/LineLength
        # /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
        # rubocop:enable Layout/LineLength
        @sdk_path ||= Pathname(Sh.capture_output("xcrun --sdk #{sdk_name} --show-sdk-path")).realpath
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
