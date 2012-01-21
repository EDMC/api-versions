# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "api-versions/version"

Gem::Specification.new do |s|
  s.name        = "api-versions"
  s.version     = Api::Versions::VERSION
  s.authors     = ["Erich Menge"]
  s.email       = ["erich.menge@me.com"]
  s.homepage    = "https://github.com/erichmenge/api-versions"
  s.summary     = "Allows you to cache routing and then inherit it in other modules."
  s.description = "Useful for API versioning."

  s.rubyforge_project = "api-versions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
