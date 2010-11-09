module Daemonizer
  class Config
    VALID_LOG_LEVELS = [:debug, :info, :warn, :error, :fatal]

    class ConfigError < StandardError;  end

    attr_reader :pool, :handler

    def initialize(pool, options)
      @pool = pool
      @options = options
      init_defaults
      validate
      initialize_handler
      @handler
    end

    def initialize_handler
      if @options[:start]
        @handler = FakeHandler.new(@options[:prepare], @options[:start], @options[:handler_options])
        @options[:start] = @options[:prepare] = nil
      elsif
        @handler = @options[:handler].new(@options[:handler_options])
      end
    end

    def init_defaults
      @options[:prepare] ||= nil
      @options[:start] ||= nil
      @options[:workers] ||= 1
      @options[:log_file] ||= "log/#{@pool}.log"
      @options[:poll_period] ||= 5
      @options[:pid_file] ||= "pid/#{@pool}.pid"
      @options[:handler] ||= nil
      @options[:handler_options] ||= {}
      @options[:callbacks] ||= {}
      @options[:on_poll] ||= []
      @options[:cow_friendly] = true if @options[:cow_friendly].nil?
      @options[:log_level] ||= :info
    end

    def validate_file(filename)
      # file validation
      if File.exist?(filename)
        if !File.file?(filename)
          raise ConfigError, "'#{filename}' is not a regular file"
        elsif !File.writable?(filename)
          raise ConfigError, "'#{filename}' is not writable!"
        end
      else # ensure directory is writable
        dir = File.dirname(filename)
        if not File.writable?(dir)
          raise ConfigError, "'#{dir}' is not writable!"
        end
        File.open(filename, 'w') { |f| f.write('') } #creating empty file
      end
    end

    def validate
      raise ConfigError, "Workers count should be more then zero" if @options[:workers] < 1
      raise ConfigError, "Poll period should be more then zero" if @options[:poll_period] < 1
      raise ConfigError, "Log level should be one of [#{VALID_LOG_LEVELS.map(&:to_s).join(',')}]" unless VALID_LOG_LEVELS.include?(@options[:log_level].to_sym)
      if @options[:handler]
        raise ConfigError, "Handler should be a class" unless @options[:handler].is_a?(Class)
        raise ConfigError, "Handler should respond to :start" unless @options[:handler].public_instance_methods.include?('start')
        raise ConfigError, "Handler set. Don't use :start and :before init in Demfile" if @options[:prepare] || @options[:start]
      else
        if @options[:prepare]
          raise ConfigError, "prepare should have block" unless @options[:prepare].is_a?(Proc)
        end
        raise ConfigError, "start should be set" if @options[:start].nil?
        raise ConfigError, "start should have block" unless @options[:start].is_a?(Proc)
      end

      validate_file(self.log_file)
      validate_file(self.pid_file)
    end

    [:workers, :poll_period, :root, :cow_friendly, :callbacks, :handler_options, :on_poll].each do |method|
      define_method method do
        @options[method.to_sym]
      end
    end

    [:log_file, :pid_file].each do |method|
      define_method method do
        File.expand_path(@options[method.to_sym], Daemonizer.root)
      end
    end

    def name
      @pool
    end
  end

end
