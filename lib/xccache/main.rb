require "pry" if ENV["XCCACHE_IMPORT_PRY"] == "true"
require "pathname"
Dir["#{__dir__}/*.rb"].sort.each { |f| require f unless f == __FILE__ }
