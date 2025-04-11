require "json"
require_relative "hash"

module XCCache
  class JSONRepresentable < HashRepresentable
    def load
      JSON.parse(path.read) if path.exist?
    rescue StandardError
      {}
    end

    def save(to: nil)
      (to || path).write(JSON.pretty_generate(raw))
    end
  end
end
