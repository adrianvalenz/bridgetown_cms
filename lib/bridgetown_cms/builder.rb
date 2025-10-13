# frozen_string_literal: true

require "bridgetown_cms/admin_routes"

module BridgetownCms
  class Builder < Bridgetown::Builder
    def build
      liquid_tag "bridgetown_cms" do
        "This plugin works!"
      end

      # Log that the cms has been loaded
      hook :site, :after_init do
        Bridgetown.logger.info "🎨 Bridgetown CMS loaded!"
        Bridgetown.logger.info "📝 Run 'bin/bridgetown apply https://github.com/adrianvalenz/bridgetown_cms' to set up admin routes"
      end
    end
  end
end
