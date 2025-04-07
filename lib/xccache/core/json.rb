require "json"

module XCCache
  class JSONRepresentable
    attr_reader :path, :raw

    def initialize(path)
      @path = path
      @raw = load_json
    end

    def load_json
      JSON.parse(path.read)
    rescue StandardError
      {}
    end

    def merge!(other)
      raw.merge!(other)
    end

    def save
      path.write(JSON.pretty_generate(raw))
    end
  end
end
