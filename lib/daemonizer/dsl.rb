class Daemonizer::DslError < StandardError; end

class Daemonizer::Dsl
  def self.evaluate(gemfile)
    builder = new
    builder.instance_eval(File.read(gemfile.to_s), gemfile.to_s, 1)
    builder.instance_variable_get("@configs")
  end

  def initialize
    @source   = nil
    @options  = {}
    @pool     = :default
    @configs  = {}
  end
  
  def set_option(option, value = nil, &block)
    @options[:handler_options] ||= {}
    if value
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
    options = @options.dup
    yield
  ensure
    @options = options
  end

  def pool(name, &blk)
    @pool = name.to_sym
    options = @options.dup
    yield
    puts "Intepolating config: #{@options.inspect} for pool #{@pool}"
    @configs[@pool] = Daemonizer::Config.new(@pool, @options)
  rescue Daemonizer::Config::ConfigError => e
    puts "* Error in pool \"#{@pool}\": #{e.to_s}. Skipping..."
  ensure
    @options = options
    @pool = nil
  end
end
