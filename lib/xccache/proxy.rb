require "xccache/core"

module XCCache
  module ProxyMixin
    include Config::Mixin

    def run_xccache_proxy(cmd)
      cmd = cmd.is_a?(Array) ? [xccache_proxy_bin_path] + cmd : [xccache_proxy_bin_path, cmd]
      cmd << "--verbose" if config.verbose?
      Sh.run(cmd)
    end

    def xccache_proxy_bin_path
      @xccache_proxy_bin_path ||= Pathname(
        Gem.find_files("../libexec/xccache-proxy")[0]
      ).expand_path
    end
  end
end
