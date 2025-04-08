require "json"

module XCCache
  class JSONRepresentable
    attr_reader :path, :raw

    def initialize(path, raw: nil)
      @path = path
      @raw = raw || load_json || {}
    end

    def load_json
      JSON.parse(path.read) if path.exist?
    rescue StandardError
      {}
    end

    def merge!(other)
      raw.merge!(other)
    end

    def save(to: nil)
      (to || path).write(JSON.pretty_generate(raw))
    end
  end
end
