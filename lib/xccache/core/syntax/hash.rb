module XCCache
  class HashRepresentable
    attr_reader :path
    attr_accessor :raw

    def initialize(path, raw: nil)
      @path = path
      @raw = raw || load || {}
    end

    def load
      raise NotImplementedError
    end

    def merge!(other)
      raw.merge!(other)
    end

    def save(to: nil)
      raise NotImplementedError
    end

    def [](key)
      raw[key]
    end

    def []=(key, value)
      raw[key] = value
    end
  end
end
