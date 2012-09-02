# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "api-versions/version"

Gem::Specification.new do |s|
  s.name        = "api-versions"
  s.version     = ApiVersions::VERSION
  s.authors     = ["Erich Menge"]
  s.email       = ["erich.menge@me.com"]
  s.homepage    = "https://github.com/erichmenge/api-versions"
  s.summary     = "An API versioning gem for Rails."
  s.description = "api-versions helps manage your app's API endpoints."

  s.rubyforge_project = "api-versions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec-rails", "~> 2.0"
  s.add_development_dependency 'ammeter',  '0.2.5'
end
