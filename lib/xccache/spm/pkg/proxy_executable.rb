module XCCache
  module SPM
    class Package
      class Proxy < Package
        class Executable
          REPO_URL = "https://github.com/trinhngocthuyen/xccache-proxy".freeze
          VERSION_OR_SHA = "0.0.1".freeze

          def run(cmd)
            env = { "FORCE_OUTPUT" => "console", "FORCE_COLOR" => "1" } if Config.instance.ansi?
            cmd = cmd.is_a?(Array) ? [bin_path.to_s] + cmd : [bin_path.to_s, cmd]
            Sh.run(cmd, env: env)
          end

          def bin_path
            @bin_path ||= lookup
          end

          private

          def lookup
            [
              local_bin_path,
              default_bin_path,
            ].find(&:exist?) || download_or_build_from_source
          end

          def default_use_downloaded?
            VERSION_OR_SHA.include?(".")
          end

          def download_or_build_from_source
            default_use_downloaded? ? download : build_from_source
          end

          def build_from_source
            UI.section("Building xccache-proxy binary from source...".magenta) do
              dir = Dir.prepare("~/.xccache/xccache-proxy", expand: true)
              git = Git.new(dir)
              git.init unless git.init?
              git.remote("add", "origin", REPO_URL) unless git.remote(capture: true)[0].strip == "origin"
              git.fetch("origin", VERSION_OR_SHA)
              git.checkout("-f", "FETCH_HEAD", capture: true)

              Dir.chdir(dir) { Sh.run("make build CONFIGURATION=release") }
              (dir / ".build" / "release" / "xccache-proxy").copy(to: default_bin_path)
            end
          end

          def download
            UI.section("Downloading xccache-proxy binary from remote...".magenta) do
              Dir.create_tmpdir do |dir|
                url = "#{REPO_URL}/releases/download/#{VERSION_OR_SHA}/xccache-proxy.zip"
                default_bin_path.parent.mkpath
                tmp_path = dir / File.basename(url)
                Sh.run("curl -fSL -o #{tmp_path} #{url} && unzip -d #{default_bin_path.parent} #{tmp_path}")
                FileUtils.chmod("+x", default_bin_path)
              end
            end
            default_bin_path
          end

          def default_bin_path
            @default_bin_path ||= begin
              dir = LIBEXEC / (default_use_downloaded? ? ".download" : ".build")
              dir / "xccache-proxy-#{VERSION_OR_SHA}" / "xccache-proxy"
            end
          end

          def local_bin_path
            @local_bin_path ||= LIBEXEC / ".local" / "xccache-proxy"
          end
        end
      end
    end
  end
end
