module XCCache
  class Git
    attr_reader :root

    def initialize(root)
      @root = Pathname(root)
    end

    def sha
      run("rev-parse --short HEAD", capture: true, log_cmd: false)[0].strip
    end

    private

    def run(cmd, options = {})
      Sh.run("git -C #{root} #{cmd}", options)
    end
  end
end
