Dir["#{__dir__}/#{File.basename(__FILE__, '.rb')}/*.rb"].sort.each { |f| require f }

module XCCache
  class Installer
    module IntegrationMixin
      include VizIntegrationMixin
      include DescsIntegrationMixin
      include BuildIntegrationMixin
      include SupportingFilesIntegrationMixin
    end
  end
end
