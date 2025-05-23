require_relative "base"

module XCCache
  class GitStorage < Storage
    attr_reader :branch

    def initialize(options = {})
      super
      if (@remote = options[:remote])
        schemes = ["http://", "https://", "git@"]
        @remote = File.expand_path(@remote) unless schemes.any? { |x| @remote.start_with?(x) }
        ensure_remote
      end
      @branch = options[:branch]
    end

    def pull
      git.fetch("--depth 1 origin #{branch}")
      git.switch("--detach FETCH_HEAD", capture: true)
      git.clean("-dfx", capture: true)
      # Re-create local branch so that it has the latest from remote
      git.branch("-D #{branch} || true", capture: true)
      git.checkout("-b #{branch}", capture: true)
    end

    def push
      return UI.info("No changes to push, cache repo is clean".magenta) if git.clean?

      git.add(".")
      git.commit("-m \"Update cache at #{Time.new}\"")
      git.push("-u origin #{branch}")
    end

    private

    def git
      @git ||= Git.new(config.spm_cache_dir)
    end

    def ensure_remote
      git.init unless git.init?
      existing = git.remote("get-url origin || true", capture: true, log_cmd: false)[0].strip
      return if @remote == existing
      return git.remote("add origin #{@remote}") if existing.empty?
      git.remote("set-url origin #{@remote}")
    end
  end
end
