require "xccache/spm"

module XCCache
  class Installer
    class Viz < Installer
      include PkgMixin
      attr_reader :out_dir

      def initialize(options = {})
        super
        @out_dir = Dir.prepare(options[:out_dir] || ".").expand_path
        @assets_dir = Dir.prepare(@out_dir / "assets")
        @html_path = @out_dir / "cachemap.html"
        @js_path = @assets_dir / "cachemap.js"
      end

      def install!
        umbrella_pkg.prepare
        create_html
        UI.info("Cachemap visualization is generated at: #{@html_path}")
      end

      private

      def create_html
        viz_json = JSON.pretty_generate(cachemap.depgraph_data)
        Template.new("cachemap.html").render(save_to: @html_path)
        Template.new("cachemap.js").render({ :json => viz_json }, save_to: @js_path)
      end
    end
  end
end
