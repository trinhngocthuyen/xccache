Dir[__FILE__.sub(".rb", "/*.rb")].sort.each { |f| require f }
