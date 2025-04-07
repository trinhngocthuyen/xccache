require "xcodeproj"

module XCCache
  class Config
    module Mixin
      def config
        Config.instance
      end
    end

    def self.instance
      @instance ||= new
    end

    attr_accessor :verbose
    alias verbose? verbose

    def sandbox
      @sandbox = Dir.prepare("xccache").expand_path
    end

    def spm_sandbox
      @spm_sandbox ||= Dir.prepare(sandbox / "packages").expand_path
    end

    def spm_binaries_sandbox
      @spm_binaries_sandbox ||= Dir.prepare(spm_sandbox / "binaries")
    end

    def spm_binaries_frameworks_dir
      @spm_binaries_frameworks_dir ||= spm_binaries_sandbox / "binaries"
    end

    def spm_umbrella_sandbox
      @spm_umbrella_sandbox ||= Dir.prepare(spm_sandbox / "umbrella")
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
  end
end
