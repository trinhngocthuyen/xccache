require_relative "base"
require "xccache/storage"
require "xccache/command/remote/pull"
require "xccache/command/remote/push"

module XCCache
  class Command
    class Remote < Command
      self.abstract_command = true
      self.summary = "Working with remote cache"
      def self.options
        [
          Options::CONFIG,
          ["--branch=foo", "Cache branch (if using git) (default: main)"],
        ].concat(super)
      end

      def initialize(argv)
        super
        @branch = argv.option("branch", "main")
      end

      def storage
        @storage ||= create_storage
      end

      private

      def create_storage
        remote_config = config.remote_config
        if (remote = remote_config["git"])
          return GitStorage.new(branch: @branch, remote: remote)
        elsif (s3_config = remote_config["s3"])
          return S3Storage.new(uri: s3_config["uri"], creds_path: s3_config["creds"])
        end
        Storage.new
      end
    end
  end
end
