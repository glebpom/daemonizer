# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "daemonizer/version"

Gem::Specification.new do |s|
  s.name        = "daemonizer"
  s.version     = Daemonizer::VERSION
  s.authors     = ["Gleb Pomykalov"]
  s.email       = ["glebpom@gmail.com"]
  s.homepage    = "http://github.com/glebpom/daemonizer"
  s.summary     = "Daemonizer allows you to easily create custom daemons on ruby. Supporting prefork model"
  s.description = "Inspired by bundler and rack. Mostly built on top of Alexey Kovyrin's loops code. http://github.com/kovyrin/loops"

  s.rubyforge_project = "daemonizer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", ">=2.1.0"
  s.add_development_dependency "mocha", ">=0.9.9"
  s.add_development_dependency "yard", ">= 0"
  s.add_development_dependency "rake"

  s.add_runtime_dependency "thor", ">= 0.13.7"
  s.add_runtime_dependency "simple-statistics", ">=0.0.3"
end
