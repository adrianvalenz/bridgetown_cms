# frozen_string_literal: true

module BridgetownCms
  class Builder < Bridgetown::Builder
    def build
      liquid_tag "bridgetown_cms" do
        "This plugin works!"
      end
    end
  end
end
