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

      def run(*args, **options)
        cmd = args.join(" ")
        UI.message("$ #{cmd}".cyan.dark) if config.verbose? && options[:log_cmd] != false

        out, err = [], []
        handle_out = proc do |line|
          if options[:capture]
            out << line
          else
            UI.puts line
          end
        end
        handle_err = proc do |line|
          if options[:capture]
            err << line
          else
            UI.puts line.strip.yellow unless options[:suppress_err]&.match(line)
          end
        end

        Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
          stdout_thread = Thread.new { stdout.each { |l| handle_out.call(l) } }
          stderr_thread = Thread.new { stderr.each { |l| handle_err.call(l) } }
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
