require "xccache/spm/desc/base"

module XCCache
  module SPM
    class Package
      class Description < BaseObject
        def self.in_dir(dir)
          path = Config.instance.spm_metadata_dir / "#{dir.basename}.json"
          begin
            raw = JSON.parse(Sh.capture_output("swift package dump-package --package-path #{dir}"))
            Description.new(path, raw: raw)
          rescue StandardError => e
            UI.error("Failed to dump package in #{dir}. Error: #{e}")
          end
        end
      end
    end
  end
end
