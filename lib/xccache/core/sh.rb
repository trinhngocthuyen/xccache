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

        out, err = [], []
        handle_out = options[:handle_out] || proc { |l| out << l }
        handle_err = options[:handle_err] || proc { |l| err << l }
        if (live_log = options[:live_log])
          handle_out = proc { |l| live_log.puts(l) }
          handle_err = proc { |l| live_log.puts(l) }
          live_log.puts("$ #{cmd}") if options[:log_cmd] != false
        elsif options[:log_cmd] != false
          UI.message("$ #{cmd}".cyan.dark)
        end

        use_popen = options[:capture] || options[:handle_out] || options[:handle_err] || options[:live_log]
        return system(cmd) || (raise GeneralError, "Command '#{cmd}' failed") unless use_popen

        popen3_args = env ? [env, cmd] : [cmd]
        Open3.popen3(*popen3_args) do |_stdin, stdout, stderr, wait_thr|
          stdout_thread = Thread.new { stdout.each { |l| handle_out.call(l.strip) } }
          stderr_thread = Thread.new { stderr.each { |l| handle_err.call(l.strip) } }
          [stdout_thread, stderr_thread].each(&:join)
          result = wait_thr.value
          result.exitstatus
          raise ExecError, "Command '#{cmd}' failed with status: #{result.exitstatus}" unless result.success?
        end
        [out.join("\n"), err.join("\n")]
      end

      private

      def log_cmd(cmd, live_log: nil)
        return live_log.puts("$ #{cmd}") if live_log
        UI.message("$ #{cmd}".cyan.dark)
      end
    end
  end
end
