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
      File.dirname(demfile)
    end
  end
  
  def self.demfile=(demfile_name)
    @@demfile = File.expand_path(demfile_name)
    @@demfile
  end
  
  def self.demfile
    if defined?(@@demfile)
      @@demfile
    else
      "Demfile"
    end
  end

  def self.[](pool)
    find_pools(pool).first or nil
  end
  
  def self.find_pools(pool_name = nil)    
    pools = Dsl.evaluate(demfile)

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
