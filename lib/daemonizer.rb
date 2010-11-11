require 'rubygems'
require 'yaml'
require 'erb'
require 'pathname'
require 'logger'
require 'simple-statistics'


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

  def self.find_daemonfile(daemonfile_name)
    previous = nil
    current  = File.expand_path(Dir.pwd)

    until !File.directory?(current) || current == previous
      filename = File.join(current, daemonfile_name)
      return filename if File.file?(filename)
      current, previous = File.expand_path("..", current), current
    end
  end

  def self.daemonfile=(daemonfile_name)
    @@daemonfile = find_daemonfile(daemonfile_name)
  end

  def self.daemonfile
    if defined?(@@daemonfile)
      @@daemonfile
    else
      "Demfile"
    end
  end

  def self.logger_context=(str)
    @@logger_context = str
  end

  def self.logger_context
    @@logger_context
  end

  def self.log_level=(level)
    @@log_level = level
  end

  def self.log_level
    @@log_level ||= :info
  end

  def self.init_logger(name, log_file)
    @@logger_file = File.open(log_file, File::WRONLY | File::APPEND)
    @@logger_file.sync = true
    @@logger = Logger.new(@@logger_file)
    set_logger_common_options
  end

  def self.set_logger_common_options
    @@logger.sev_threshold = Logger::const_get(Daemonizer.log_level.to_s.upcase) || Logger::INFO
    @@logger.formatter = Proc.new do |severity, datetime, progname, msg|
      "%s %s -- %s -- %s\n" % [ datetime.strftime("%Y-%m-%d %H:%M:%S"), severity, Daemonizer.logger_context, msg ]
    end
  end

  def self.reopen_log_file
    true #do not need it in append-only mode
  end

  def self.flush_logger
    @@logger_file.flush
  end

  def self.init_console_logger(name)
    @@logger_file = STDOUT
    @@logger = Logger.new(@@logger_file)
    set_logger_common_options
  end

  def self.logger
    if defined?(@@logger)
      @@logger
    else
      nil
    end
  end

  def self.[](pool)
    find_pools(pool).first or nil
  end

  def self.find_pools(pool_name = nil)
    pools = Dsl.evaluate(File.read(daemonfile.to_s), daemonfile.to_s).process

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
