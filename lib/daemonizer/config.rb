module Daemonizer
  class Config
    class ConfigError < StandardError;  end

    attr_reader :pool, :handler

    def initialize(pool, options)
      @pool = pool
      @options = options
      init_defaults
      validate
      initialize_handler
    end
    
    def option(key)
      if handler
        handler.option(key) 
      else
        raise ConfigError, "handler is not initialized"
      end
    end

    def initialize_handler
      if @options[:after_init]
        @handler = FakeHandler.new(@options[:before_init], @options[:after_init], @options)
        @options[:after_init] = @options[:before_init] = nil
      elsif
        @handler = @options[:handler].new(@options[:handler_options])
      end
      @handler.logger = @logger
    end

    def init_defaults
      @options[:before_init] ||= nil
      @options[:after_init] ||= nil
      @options[:workers] ||= 1
      @options[:log_file] ||= "log/#{@pool}.log"
      @options[:poll_period] ||= 5
      @options[:pid_file] ||= "pid/#{@pool}.pid"
      @options[:handler] ||= nil
      @options[:handler_options] ||= {}
      @options[:cow_friendly] = true if @options[:cow_friendly].nil?
    end

    def validate
      raise ConfigError, "Workers count should be more then zero" if @options[:workers] < 1
      raise ConfigError, "Poll period should be more then zero" if @options[:poll_period] < 1
      if @options[:handler]
        raise ConfigError, "Handler should be a class" unless @options[:handler].is_a?(Class)
        raise ConfigError, "Handler should respond to :after_init" unless @options[:handler].public_instance_methods.include?('after_init')
        raise ConfigError, "Handler set. Don't use :after_init and :before init in Demfile" if @options[:before_init] || @options[:after_init]
      else
        if @options[:before_init]
          raise ConfigError, "before_init should have block" unless @options[:before_init].is_a?(Proc)
        end
        raise ConfigError, "after_init should be set" if @options[:after_init].nil?
        raise ConfigError, "after_init should have block" unless @options[:after_init].is_a?(Proc)
      end
    end

    [:workers, :poll_period, :root, :cow_friendly].each do |method|
      define_method method do
        @options[method.to_sym]
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
  end

end
