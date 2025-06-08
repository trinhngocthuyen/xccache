require "xccache/core/sh"

module XCCache
  module Swift
    class Sdk
      attr_reader :name, :arch, :vendor, :platform
      attr_accessor :version

      NAME_TO_PLATFORM = {
        :iphonesimulator => :ios,
        :iphoneos => :ios,
        :macos => :macos,
        :watchos => :watchos,
        :watchsimulator => :watchos,
        :appletvos => :tvos,
        :appletvsimulator => :tvos,
        :xros => :xros,
        :xrsimulator => :xros,
      }.freeze

      def initialize(name, version: nil)
        @name = name.to_sym
        @vendor = "apple"
        @arch = "arm64"
        @platform = NAME_TO_PLATFORM.fetch(@name, @name)
        @version = version
        return if NAME_TO_PLATFORM.key?(@name)
        raise GeneralError, "Unknown sdk: #{@name}. Must be one of #{NAME_TO_PLATFORM.keys}"
      end

      def to_s
        name.to_s
      end

      def triple(with_vendor: true, with_version: false)
        cmps = [arch]
        cmps << vendor if with_vendor
        cmps << (with_version && version ? "#{platform}#{version}" : platform.to_s)
        cmps << "simulator" if simulator?
        cmps.join("-")
      end

      def sdk_name
        name == :macos ? :macosx : name
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

      def simulator?
        name.to_s.end_with?("simulator")
      end
    end
  end
end
