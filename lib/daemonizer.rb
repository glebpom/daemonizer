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
    @@root
  end

end

require File.dirname(__FILE__) + '/../lib/daemonizer/autoload'
