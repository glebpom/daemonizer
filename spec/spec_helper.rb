#$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'daemonizer'
require 'fileutils'
require 'rubygems'
require 'rspec'
require 'open3'

Dir["#{File.expand_path('support', File.dirname(__FILE__))}/*.rb"].each do |file|
  require file
end

$debug    = false
$show_err = true

FileUtils.rm_rf(Spec::Path.app_root)

RSpec.configure do |config|
  config.include Spec::Helpers
  config.include Spec::Path
  config.include Spec::DaemonfileFactory
  config.include Spec::Processes

  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true


  original_wd = Dir.pwd

  config.before :each do
    reset!
    in_app_root
  end

  config.after :each do
    Dir.chdir(original_wd)
  end
end

class SpecHandler < Daemonizer::Handler
  def initialize(*args)
    @worker_id = 1
    @workers_count = 1
    super
  end

  def prepare(starter, &block)

  end

  def start
    self
  end
end
