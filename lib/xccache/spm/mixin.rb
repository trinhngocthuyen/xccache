module XCCache
  module PkgMixin
    include Config::Mixin

    def umbrella_pkg
      @umbrella_pkg ||= UmbrellaPkg.new(
        path: config.spm_umbrella_sandbox,
        projects: config.projects,
        lockfile: config.lockfile,
        cachemap: config.cachemap,
        metadata_dir: config.spm_metadata_dir,
      )
    end
  end
end
