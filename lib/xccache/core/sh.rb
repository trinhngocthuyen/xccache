require "open3"
require "xccache/core/config"
require "xccache/core/log"
require "xccache/core/error"

module XCCache
  class Sh
    class ExecError < BaseError
    end

    class << self
      include Config::Mixin

      def capture_output(cmd)
        run(cmd, capture: true, log_cmd: false)[0].strip
      end

      def run(*args, env: nil, **options)
        cmd = args.join(" ")
        UI.message("$ #{cmd}".cyan.dark) if config.verbose? && options[:log_cmd] != false
        return system(cmd) || (raise GeneralError, "Command '#{cmd}' failed") unless options[:capture]

        out, err = [], []
        popen3_args = env ? [env, cmd] : [cmd]
        Open3.popen3(*popen3_args) do |_stdin, stdout, stderr, wait_thr|
          stdout_thread = Thread.new { stdout.each { |l| out << l } }
          stderr_thread = Thread.new { stderr.each { |l| err << l } }
          [stdout_thread, stderr_thread].each(&:join)
          result = wait_thr.value
          result.exitstatus
          raise ExecError, "Command '#{cmd}' failed with status: #{result.exitstatus}" unless result.success?
        end
        [out.join("\n"), err.join("\n")]
      end
    end
  end
end
