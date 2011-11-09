require "bundler/gem_tasks"

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
