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

    def lockfile
      @lockfile ||= Lockfile.new(Pathname("xccache.lock"))
    end

    def projects
      @projects ||= Pathname(".").glob("*.xcodeproj").map do |p|
        Xcodeproj::Project.open(p)
      end
    end
  end
end
