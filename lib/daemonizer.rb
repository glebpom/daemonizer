require 'rubygems'
require 'yaml'
require 'erb'
require 'pathname'
require 'log4r'

include Log4r

module Daemonizer
  
  def self.root=(value)
    @@root = value
  end

  def self.root
    if defined?(@@root)
      @@root
    else
      File.dirname(daemonfile)
    end
  end
  
  def self.daemonfile=(daemonfile_name)
    @@daemonfile = File.expand_path(daemonfile_name)
    @@daemonfile
  end
  
  def self.daemonfile
    if defined?(@@daemonfile)
      @@daemonfile
    else
      "Demfile"
    end
  end
  
  def self.init_logger(name, log_file)
    @@logger = Logger.new name
    outputter = FileOutputter.new('log', :filename => log_file, :trunc => false)
    outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
    @@logger.outputters = outputter
    @@logger.level = INFO
  end
  
  def self.reopen_log_file
    log_file = @@logger.outputters.first.filename
    @@logger.outputters.each do |o|
      o.flush
      o.close
    end
    outputter = FileOutputter.new('log', :filename => log_file, :trunc => false)
    outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
    @@logger.outputters = outputter
  end
  
  def self.flush_logger
    @@logger.outputters.each do |o| 
      o.flush
    end
  end
  
  def self.init_console_logger(name)
    @@logger = Logger.new name
    outputter = Outputter.stdout
    outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
    @@logger.outputters = outputter
  end
  
  def self.logger
    @@logger
  end

  def self.[](pool)
    find_pools(pool).first or nil
  end
  
  def self.find_pools(pool_name = nil)    
    pools = Dsl.evaluate(daemonfile)

    if pool_name
      if pool = pools[pool_name.to_sym]
        [pool]
      else
        puts "#{pool_name} is not configured"
        []
      end
    else
      pools.values
    end
  end
  
end

require File.dirname(__FILE__) + '/../lib/daemonizer/autoload'
