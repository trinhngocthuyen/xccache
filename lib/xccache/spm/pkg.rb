Dir["#{__dir__}/pkg/*.rb"].sort.each { |f| require f }

module XCCache
  module PkgMixin
    include Config::Mixin

    def binaries_pkg
      @binaries_pkg ||= BinariesPkg.new(
        path: Dir.prepare(config.spm_binaries_sandbox),
        projects: config.projects,
        cachemap: config.cachemap,
      )
    end

    def umbrella_pkg
      @umbrella_pkg ||= UmbrellaPkg.new(
        path: config.spm_umbrella_sandbox,
        projects: config.projects,
        cachemap: config.cachemap,
      )
    end
  end
end
