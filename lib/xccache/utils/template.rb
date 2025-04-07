require "erb"

module XCCache
  class Template
    def initialize(name)
      @name = name
      @path = Gem.find_files("xccache/assets/templates/#{name}").first
    end

    def render(hash, save_to: nil)
      rendered = ERB.new(File.read(@path)).result_with_hash(hash)
      Pathname(save_to).write(rendered) unless save_to.nil?
      rendered
    end
  end
end
