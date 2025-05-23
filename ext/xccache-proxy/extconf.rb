require "mkmf"
require "fileutils"
require "tmpdir"

INSTALL_DIR = File.expand_path("../../libexec", __dir__)
REPO_DIR = File.expand_path("~/.xccache/xcache-proxy")
REPO_URL = "git@github.com:trinhngocthuyen/xccache-proxy.git".freeze # FIXME: Change to https URL
BRANCH = "main".freeze
CONFIG = "debug".freeze

def run(cmd)
  cmd = cmd.join(" ") if cmd.is_a?(Array)
  puts "Run: $ #{cmd}"
  system(cmd) or abort "Failed to run cmd: #{cmd}"
end

def build_from_source
  puts "Cloning xccache-proxy..."
  run("rm -rf #{REPO_DIR} && git clone #{REPO_URL} --depth=1 --branch=#{BRANCH} #{REPO_DIR}")

  puts "Building xccache-proxy..."
  run(
    "set -o pipefail && swift build " \
    "--configuration #{CONFIG} " \
    "--product xccache-proxy " \
    "--package-path #{REPO_DIR} " \
    "2>&1 | tee #{REPO_DIR}/install.log"
  )

  FileUtils.mkpath(INSTALL_DIR)
  ["xccache-proxy", "libSwiftPM.dylib"].each do |p|
    FileUtils.cp("#{REPO_DIR}/.build/#{CONFIG}/#{p}", "#{INSTALL_DIR}/#{p}")
    FileUtils.chmod("+x", "#{INSTALL_DIR}/#{p}")
  end
end

build_from_source
create_makefile("dummy") # required for extensions
