module XCCache
  module SPM
    class Package
      module UmbrellaVizMixin
        def gen_cachemap_viz
          stats = config.cachemap.stats
          html_path = config.sandbox / "cachemap.html"
          js_path = Dir.prepare(config.sandbox / "assets") / "cachemap.js"
          css_path = config.sandbox / "assets" / "style.css"

          root_dir = Pathname(".").expand_path
          to_relative = proc do |p|
            p.to_s.start_with?(root_dir.to_s) ? p.relative_path_from(root_dir).to_s : p.to_s
          end

          UI.info("Cachemap visualization: #{html_path}")
          Template.new("cachemap.html").render(
            {
              :root_dir => root_dir.to_s,
              :root_dir_short => root_dir.basename.to_s,
              :lockfile_path => config.lockfile.path.to_s,
              :lockfile_path_short => to_relative.call(config.lockfile.path),
              :binaries_dir => config.spm_binaries_dir.to_s,
              :binaries_dir_short => to_relative.call(config.spm_binaries_dir),
              :desc_hit => stats[:hit],
              :desc_missed => stats[:missed],
              :desc_ignored => stats[:ignored],
            },
            save_to: html_path
          )
          Template.new("cachemap.js").render(
            { :json => JSON.pretty_generate(config.cachemap.depgraph_data) },
            save_to: js_path
          )
          Template.new("cachemap.style.css").render(save_to: css_path)
        end
      end
    end
  end
end
