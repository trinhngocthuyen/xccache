require "xccache/swift/swiftc"
require "xccache/utils/template"
require "xccache/cache/cachemap"

module XCCache
  class BinariesPkg
    attr_reader :path, :projects, :cachemap

    def initialize(options)
      @path = options[:path]
      @projects = options[:projects]
      @cachemap = options[:cachemap]
    end

    def prepare
      create!
    end

    private

    def create!
      UI.message("Create binary package at #{path}")
      Template.new("binaries.Package.swift").render(
        {
          :json => JSON.pretty_generate(manifest_data),
          :swift_version => Swift::Swiftc.version_without_patch,
        },
        save_to: path / "Package.swift",
      )
      # Create sources dirs
      projects.flat_map(&:targets).each do |target|
        dir = Dir.prepare(path / "Sources" / target.xccache_binary_name)
        (dir / "dummy.swift").write("")
      end
    end

    def manifest_data
      targets = cachemap.raw.values.flat_map do |hash|
        hash.map do |target_name, deps|
          # TODO: Distinguish cache hit/miss
          binary_deps = deps.map { |d| "#{d.split('/')[-1]}.binary" }
          ["#{target_name}.binary", binary_deps]
        end
      end.to_h
      { "products" => { "libraries" => targets.keys }, "targets" => targets }
    end
  end
end
