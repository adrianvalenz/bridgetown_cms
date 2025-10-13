# frozen_string_literal: true

require_relative "lib/bridgetown_cms/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown_cms"
  spec.version       = BridgetownCms::VERSION
  spec.author        = "Adrian Valenzuela"
  spec.email         = "adrianvalenz.web@gmail.com"
  spec.summary       = "Best CMS for Bridgetown"
  spec.homepage      = "https://github.com/adrianvalenz/bridgetown_cms"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r!^(test|script|spec|features|frontend)/!)
  end
  spec.require_paths = ["lib"]
  # Uncomment this if you wish to supply a companion NPM package:
  # spec.metadata      = { "yarn-add" => "bridgetown_cms@#{BridgetownCms::VERSION}" }

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_dependency "bridgetown", ">= 1.2.0", "< 3.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rubocop-bridgetown", "~> 0.3"
  spec.metadata["rubygems_mfa_required"] = "true"
end
