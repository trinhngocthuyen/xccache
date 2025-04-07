require "xccache/core"
Dir["#{__dir__}/xcodeproj/*.rb"].sort.each { |f| require f }
