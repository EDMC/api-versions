source "http://rubygems.org"

# Specify your gem's dependencies in api-versions.gemspec
gemspec

case ENV['RAILS_VERSION']
when /master/
  gem "rails", github: "rails/rails"
when /4-0-stable/
  gem "rails", github: "rails/rails", branch: "4-0-stable"
when /3-2-stable/
  gem "rails", github: "rails/rails", branch: "3-2-stable"
when /3-1-stable/
  gem "rails", github: "rails/rails", branch: "3-1-stable"
when /3-0-stable/
  gem "rails", github: "rails/rails", branch: "3-0-stable"
else
  gem "rails", ENV['RAILS_VERSION']
end
