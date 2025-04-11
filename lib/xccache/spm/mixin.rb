module XCCache
  module PkgMixin
    include Config::Mixin

    def umbrella_pkg
      @umbrella_pkg ||= UmbrellaPkg.new
    end
  end
end
