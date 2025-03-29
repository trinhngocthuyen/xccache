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
  end
end
