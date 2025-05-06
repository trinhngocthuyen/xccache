module XCCache
  module PkgMixin
    include Config::Mixin

    def umbrella_pkg
      @umbrella_pkg ||= SPM::Package::Umbrella.new(
        root_dir: config.spm_umbrella_sandbox,
        warn_if_not_direct_target: false,
      )
    end
  end
end
