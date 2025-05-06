require "cfpropertylist"
require_relative "hash"

module XCCache
  class PlistRepresentable < HashRepresentable
    def load
      plist = CFPropertyList::List.new(file: path)
      CFPropertyList.native_types(plist.value)
    rescue StandardError
      {}
    end

    def save(to: nil)
      raise NotImplementedError
    end
  end
end
