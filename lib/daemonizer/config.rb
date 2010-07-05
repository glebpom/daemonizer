module Daemonizer
  class Config
    class ConfigError < StandardError;  end

    attr_reader :pool

    def initialize(pool, options)
      @pool = pool
      @options = options
      init_defaults
      init_logger
      validate
    end
    
    def init_logger
      @logger = Logger.new @pool.to_s
      outputter = FileOutputter.new('log', :filename => @options[:log_file])
      outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
      @logger.outputters = outputter
      @logger.level = INFO
      GDC.set "#{Process.pid}/monitor"
    end
    
    def init_defaults
      @options[:before_init] ||= Proc.new
      @options[:engine] ||= :fork
      @options[:workers] ||= 1
      @options[:log_file] ||= "log/#{@pool}.log"
      @options[:poll_period] ||= 5
    end
    
    def validate
      Daemonizer.report_fatal_error "Workers count should be more then zero", @logger if @options[:workers] < 1
      Daemonizer.report_fatal_error "Engine #{@options[:engine]} is not known", @logger unless [:fork, :thread].include?(@options[:engine])
      if @options[:before_init]
        Daemonizer.report_fatal_error "before_init should have block", @logger unless @options[:before_init].is_a?(Proc)
      end
      Daemonizer.report_fatal_error "after_init should be set", @logger if @options[:after_init].nil?
      Daemonizer.report_fatal_error "after_init should have block", @logger unless @options[:after_init].is_a?(Proc)
      Daemonizer.report_fatal_error "Poll period should be more then zero", @logger if @options[:poll_period] < 1
    end
    
    [:before_init, :engine, :workers, :after_init, :poll_period, :log_file].each do |method|
      define_method method do
        @options[method.to_sym]
      end
    end
    
    def name
      @pool
    end
    
    def logger
      @logger
    end
    
    def pid_file
      "tmp/pid-#{@pool}"
    end

  end
  
end
