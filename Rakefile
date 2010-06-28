require 'rubygems'
require 'rubygems/specification'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "daemonizer"
    gemspec.summary = "Daemonizer allows you to easily create custom daemons on ruby. Supporting preforked and threaded models."
    gemspec.description = "Inspired by bundler. Mostly build on top of Alexey Kovyrin's loops code. http://github.com/kovyrin/loops"
    gemspec.email = "glebpom@gmail.com"
    gemspec.homepage = "http://github.com/glebpom/daemonizer"
    gemspec.authors = ["Gleb Pomykalov"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

begin
  require 'spec/rake/spectask'
rescue LoadError
  raise 'Run `gem install rspec` to be able to run specs'
else
  task :clear_tmp do
    FileUtils.rm_rf(File.expand_path("../tmp", __FILE__))
  end

  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts  = %w(-fs --color)
    t.warning    = true
  end
  task :spec
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yard) do |t|
    t.options = ['--title', 'Loops Documentation']
    if ENV['PRIVATE']
      t.options.concat ['--protected', '--private']
    else
      t.options.concat ['--protected', '--no-private']
    end
  end
rescue LoadError
  puts 'Yard not available. Install it with: sudo gem install yard'
end
