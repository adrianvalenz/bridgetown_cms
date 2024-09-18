# rubocop:disable all
module BridgetownCms
  class PluginComponent < Bridgetown::Component
    def initialize(hi:)
      @hi = hi
    end

    # You can remove this and add an ERB, Serbea, etc. template file…or you can
    # use something like Phlex if you're feeling adventurous!
    def template
      <<~HTML
        Well hello there #{hi}!
      HTML
    end
  end
end
# rubocop:enable all
