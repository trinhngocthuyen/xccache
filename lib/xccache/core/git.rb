module XCCache
  class Git
    attr_reader :root

    def initialize(root)
      @root = Pathname(root).expand_path
    end

    def run(*args, **kwargs)
      Sh.run("git -C #{root}", *args, **kwargs)
    end

    def sha
      run("rev-parse --short HEAD", capture: true, log_cmd: false)[0].strip
    end

    def clean?
      status("--porcelain", capture: true, log_cmd: false)[0].empty?
    end

    def init?
      !root.glob(".git").empty?
    end

    %i[init checkout fetch pull push clean add commit branch remote switch status].each do |name|
      define_method(name) do |*args, **kwargs|
        run(name, *args, **kwargs)
      end
    end
  end
end
