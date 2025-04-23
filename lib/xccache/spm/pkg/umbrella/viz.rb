module XCCache
  module SPM
    class Package
      module UmbrellaVizMixin
        def gen_cachemap_viz
          html_path = config.sandbox / "cachemap.html"
          js_path = Dir.prepare(config.sandbox / "assets") / "cachemap.js"
          UI.message("Cachemap visualization: #{html_path}")
          Template.new("cachemap.html").render(
            { :js_path => js_path.relative_path_from(html_path.parent) },
            save_to: html_path
          )
          Template.new("cachemap.js").render(
            { :json => JSON.pretty_generate(config.cachemap.depgraph_data) },
            save_to: js_path
          )
        end
      end
    end
  end
end
