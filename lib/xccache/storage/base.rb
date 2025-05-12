module XCCache
  class Storage
    include Config::Mixin

    def initialize(options = {}); end

    def pull
      print_warnings
    end

    def push
      print_warnings
    end

    private

    def print_warnings
      UI.warn <<~DESC
        Do nothing as remote cache is not set up yet.

        To set it up, specify `remote` in `xccache.yml`.
        See: https://github.com/trinhngocthuyen/xccache/blob/main/docs/configuration.md#remote
      DESC
    end
  end
end
