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
    gemspec.add_dependency('simple-statistics', '>=0.0.3')
    gemspec.add_development_dependency "rspec", ">=2.1.0"
    gemspec.add_development_dependency "mocha", ">=0.9.9"
    gemspec.add_development_dependency "yard", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fs --color)
  t.ruby_opts  = %w(-w)
end

desc  "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov => :spec) do |t|
  t.rcov = true
  t.rcov_opts = %w{--exclude gems\/,spec\/}
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
