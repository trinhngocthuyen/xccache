require "xcodeproj"
require "xccache/core/syntax/yml"

module XCCache
  class Config < YAMLRepresentable
    module Mixin
      def config
        Config.instance
      end
    end

    def self.instance
      @instance ||= new(Pathname("xccache.yml").expand_path)
    end

    attr_accessor :verbose
    alias verbose? verbose

    def sandbox
      @sandbox = Dir.prepare("xccache").expand_path
    end

    def spm_sandbox
      @spm_sandbox ||= Dir.prepare(sandbox / "packages").expand_path
    end

    def spm_binaries_frameworks_dir
      @spm_binaries_frameworks_dir ||= spm_umbrella_sandbox / "binaries"
    end

    def spm_umbrella_sandbox
      @spm_umbrella_sandbox ||= Dir.prepare(spm_sandbox / "umbrella")
    end

    def spm_metadata_dir
      @spm_metadata_dir ||= Dir.prepare(spm_sandbox / "metadata")
    end

    def lockfile
      @lockfile ||= Lockfile.new(Pathname("xccache.lock"))
    end

    def cachemap
      @cachemap ||= Cache::Cachemap.new(sandbox / "cachemap.json")
    end

    def projects
      @projects ||= Pathname(".").glob("*.xcodeproj").map do |p|
        Xcodeproj::Project.open(p)
      end
    end

    def ignore_list
      raw["ignore"] || []
    end

    def ignore?(item)
      ignore_list.any? { |p| File.fnmatch(p, item) }
    end
  end
end
