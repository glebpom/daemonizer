require 'rubygems'
require 'yaml'
require 'erb'
require 'pathname'
require 'log4r'

include Log4r

module Daemonizer
  
  def self.report_fatal_error(error, logger)
    if logger
      logger.fatal error
      exit 1
    else
      raise error
    end
  end
end

require File.join('lib/daemonizer/autoload')
