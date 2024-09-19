# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "bridgetown", ENV["BRIDGETOWN_VERSION"] if ENV["BRIDGETOWN_VERSION"]
gem "bridgetown-routes"

group :test do
  gem "minitest"
  gem "minitest-profile"
  gem "minitest-reporters"
end
