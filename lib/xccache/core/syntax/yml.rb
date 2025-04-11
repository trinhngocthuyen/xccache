require "yaml"
require_relative "hash"

module XCCache
  class YAMLRepresentable < HashRepresentable
    def load
      YAML.safe_load(path.read) if path.exist?
    rescue StandardError
      {}
    end

    def save(to: nil)
      (to || path).write(raw.to_yaml)
    end
  end
end
