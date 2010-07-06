require 'rubygems'
require 'rubygems/specification'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "daemonizer"
    gemspec.summary = "Daemonizer allows you to easily create custom daemons on ruby. Supporting preforked and threaded models."
    gemspec.description = "Inspired by bundler and rack. Mostly built on top of Alexey Kovyrin's loops code. http://github.com/kovyrin/loops"
    gemspec.email = "glebpom@gmail.com"
    gemspec.homepage = "http://github.com/glebpom/daemonizer"
    gemspec.authors = ["Gleb Pomykalov"]
    gemspec.add_dependency('log4r', '>= 1.1.8')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yard) do |t|
    t.options = ['--title', 'Daemonizer Documentation']
    if ENV['PRIVATE']
      t.options.concat ['--protected', '--private']
    else
      t.options.concat ['--protected', '--no-private']
    end
  end
rescue LoadError
  puts 'Yard not available. Install it with: sudo gem install yard'
end
