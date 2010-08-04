# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{daemonizer}
  s.version = "0.4.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gleb Pomykalov"]
  s.date = %q{2010-08-04}
  s.default_executable = %q{daemonizer}
  s.description = %q{Inspired by bundler and rack. Mostly built on top of Alexey Kovyrin's loops code. http://github.com/kovyrin/loops}
  s.email = %q{glebpom@gmail.com}
  s.executables = ["daemonizer"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    "LICENSE",
     "README.md",
     "ROADMAP",
     "Rakefile",
     "VERSION",
     "bin/daemonizer",
     "daemonizer.gemspec",
     "lib/daemonizer.rb",
     "lib/daemonizer/autoload.rb",
     "lib/daemonizer/cli.rb",
     "lib/daemonizer/config.rb",
     "lib/daemonizer/daemonize.rb",
     "lib/daemonizer/dsl.rb",
     "lib/daemonizer/engine.rb",
     "lib/daemonizer/errors.rb",
     "lib/daemonizer/handler.rb",
     "lib/daemonizer/option.rb",
     "lib/daemonizer/process_manager.rb",
     "lib/daemonizer/stats.rb",
     "lib/daemonizer/worker.rb",
     "lib/daemonizer/worker_pool.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/test_spec.rb"
  ]
  s.homepage = %q{http://github.com/glebpom/daemonizer}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Daemonizer allows you to easily create custom daemons on ruby. Supporting prefork model}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/test_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<thor>, [">= 0.13.7"])
      s.add_runtime_dependency(%q<simple-statistics>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<thor>, [">= 0.13.7"])
      s.add_dependency(%q<simple-statistics>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<thor>, [">= 0.13.7"])
    s.add_dependency(%q<simple-statistics>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

