require 'rubygems'
require 'rubygems/specification'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "daemonizer"
    gemspec.summary = "Daemonizer allows you to easily create custom daemons on ruby. Supporting prefork model"
    gemspec.description = "Inspired by bundler and rack. Mostly built on top of Alexey Kovyrin's loops code. http://github.com/kovyrin/loops"
    gemspec.email = "glebpom@gmail.com"
    gemspec.homepage = "http://github.com/glebpom/daemonizer"
    gemspec.authors = ["Gleb Pomykalov"]
    gemspec.add_dependency('thor', '>= 0.13.7')
    gemspec.add_dependency('simple-statistics', '>= 0')
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "yard", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
