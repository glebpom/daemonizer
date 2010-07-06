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
      outputter = FileOutputter.new('log', :filename => self.log_file)
      outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
      @logger.outputters = outputter
      @logger.level = INFO
      GDC.set "#{Process.pid}/monitor"
    end
    
    def init_defaults
      @options[:before_init] ||= nil
      @options[:engine] ||= :fork
      @options[:workers] ||= 1
      @options[:log_file] ||= "log/#{@pool}.log"
      @options[:poll_period] ||= 5
      @options[:pid_file] ||= "pid/#{@pool}.pid"
      @options[:handler] ||= nil
    end
    
    def validate
      raise ConfigError, "Workers count should be more then zero" if @options[:workers] < 1
      raise ConfigError, "Engine #{@options[:engine]} is not known" unless [:fork, :thread].include?(@options[:engine])

      raise ConfigError, "Poll period should be more then zero" if @options[:poll_period] < 1
      if @options[:handler]
        raise ConfigError, "Handler should be a class" unless @options[:handler].is_a?(Class)
        raise ConfigError, "Handler should respond to :after_init" unless @options[:handler].respond_to?(:after_init)
        raise ConfigError, "Handler set. Don't use :after_init and :before init in Demfile" if @options[:before_init] || @options[:after_init]
      else
        if @options[:before_init]
          raise ConfigError, "before_init should have block" unless @options[:before_init].is_a?(Proc)
        end
        raise ConfigError, "after_init should be set" if @options[:after_init].nil?
        raise ConfigError, "after_init should have block" unless @options[:after_init].is_a?(Proc)
      end
    end
    
    [:engine, :workers, :poll_period, :root].each do |method|
      define_method method do
        @options[method.to_sym]
      end
    end
     
    def before_init
      if handler = @options[:handler]
        handler.method(:before_init)
      else
        @options[:before_init]
      end or Proc.new { |logger, block| block.call }
    end

    def after_init
      if handler = @options[:handler]
        handler.method(:after_init)
      else
        @options[:after_init]
      end
    end
        
    [:log_file, :pid_file].each do |method|
      define_method method do
        File.join(Daemonizer.root, @options[method.to_sym])
      end
    end
    
    def name
      @pool
    end
    
    def logger
      @logger
    end
  end

end
