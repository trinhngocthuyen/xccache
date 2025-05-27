module XCCache
  module SPM
    class Package
      class Proxy < Package
        class Executable
          VERSION = "0.0.1rc3".freeze

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
            ].find(&:exist?) || download
          end

          def download
            UI.section("Downloading xccache-proxy binary from remote...".magenta) do
              Dir.create_tmpdir do |dir|
                url = "https://github.com/trinhngocthuyen/xccache-proxy/releases/download/#{VERSION}/xccache-proxy.zip"
                default_bin_path.parent.mkpath
                tmp_path = dir / File.basename(url)
                Sh.run("curl -fSL -o #{tmp_path} #{url} && unzip -d #{default_bin_path.parent} #{tmp_path}")
                FileUtils.chmod("+x", default_bin_path)
              end
            end
            default_bin_path
          end

          def default_bin_path
            @default_bin_path ||= LIBEXEC / ".download" / "xccache-proxy-#{VERSION}" / "xccache-proxy"
          end

          def local_bin_path
            @local_bin_path ||= LIBEXEC / ".local" / "xccache-proxy"
          end
        end
      end
    end
  end
end
