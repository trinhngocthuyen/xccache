Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }
