module XCCache
  module PkgMixin
    include Config::Mixin

    def umbrella_pkg
      proxy_pkg.umbrella
    end

    def proxy_pkg
      @proxy_pkg ||= SPM::Package::Proxy.new(root_dir: config.spm_proxy_sandbox)
    end
  end
end
