# frozen_string_literal: true

require "bridgetown"
require "bridgetown_cms/builder"

# @param config [Bridgetown::Configuration::ConfigurationDSL]
Bridgetown.initializer :bridgetown_cms do |config|
  # Add code here which will run when a site includes
  # `init :bridgetown_cms`
  # in its configuration

  # Add default configuration data:
  config.bridgetown_cms ||= {}
  config.bridgetown_cms.my_setting ||= 123

  # Register your builder:
  config.builder BridgetownCms::Builder

  # You can optionally supply a source manifest:
  config.source_manifest(
    origin: BridgetownCms,
    components: File.expand_path("../components", __dir__),
    layouts: File.expand_path("../layouts", __dir__),
    content: File.expand_path("../content", __dir__)
  )
end
