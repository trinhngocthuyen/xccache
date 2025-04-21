require "erb"
require "xccache/core/error"

module XCCache
  class Template
    attr_reader :name, :path

    def initialize(name)
      @name = name
      @path = Gem.find_files("xccache/assets/templates/#{name}.template").first
    end

    def render(hash = {}, save_to: nil)
      raise GeneralError, "Template not found: #{name}" if path.nil?

      rendered = ERB.new(File.read(@path)).result_with_hash(hash)
      Pathname(save_to).write(rendered) unless save_to.nil?
      rendered
    end
  end
end
