class Daemonizer::Dsl
  class DslError < StandardError; end

  def self.evaluate(daemonfile, daemonfile_name = 'Daemonfile')
    builder = new
    builder.instance_eval(daemonfile, daemonfile_name.to_s, 1)
    builder
  end

  def configs
    @configs
  end

  def process
    result = {}
    @configs.each do |k,v|
      result[k] = Daemonizer::Config.new(k, v)
    end
    result
  end

  def initialize
    @source   = nil
    @options  = {}
    @pool     = :default
    @configs  = {}
  end

  def set_option(option, value = nil, &block)
    @options[:handler_options] ||= {}
    if not value.nil?
      @options[:handler_options][option.to_sym] = Daemonizer::Option.new(option, value)
    elsif block_given?
      @options[:handler_options][option.to_sym] = Daemonizer::Option.new(option, block, true)
    else
      raise DslError, "you should supply block or value to :set_option"
    end
  end

  CALLBACKS = [:before_prepare, :after_prepare, :before_start]
  def set_callback(callback, &block)
    return unless CALLBACKS.include?(callback.to_sym)
    @options[:callbacks] ||= {}
    @options[:callbacks][callback.to_sym] ||= []
    @options[:callbacks][callback.to_sym] << block
  end

  CALLBACKS.each do |callback|
    define_method callback.to_sym do |&block|
      set_callback callback.to_sym, &block
    end
  end

  def log_level(level)
    @options[:log_level] = level.to_sym
  end

  def on_poll(&block)
    @options[:on_poll] ||= []
    @options[:on_poll] << block
  end


  def not_cow_friendly
    @options[:cow_friendly] = false
  end

  def handler(handler)
    @options[:handler] = handler
  end

  def poll_period(seconds)
    @options[:poll_period] = seconds.to_i
  end

  def log_file(log)
    @options[:log_file] = log
  end

  def workers(num)
    @options[:workers] = num.to_i
  end

  def prepare(&blk)
    @options[:prepare] = blk
  end

  def start(&blk)
    @options[:start] = blk
  end

  def pid_file(pid)
    @options[:pid_file] = pid
  end

  def settings_group(&blk)
    options = config_copy
    yield
  ensure
    @options = options
  end

  def pool(name, &blk)
    @pool = name.to_sym
    options = config_copy
    yield
    @configs[@pool] = @options.clone
  rescue Daemonizer::Config::ConfigError => e
    puts "* Error in pool \"#{@pool}\": #{e.to_s}. Skipping..."
  ensure
    @options = options
    @pool = nil
  end

  def config_copy
    options = @options.dup
    options[:handler_options] = @options[:handler_options].dup if @options[:handler_options]
    options[:callbacks] = @options[:callbacks].dup if @options[:callbacks]
    options[:on_poll] = @options[:on_poll].dup if @options[:on_poll]
    options
  end
end
