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
  
  def engine(name)
    @options[:engine] = name.to_sym
  end
  
  def before_init(&blk)
    @options[:before_init] = blk
  end
  
  def after_init(&blk)
    @options[:after_init] = blk
  end
  
  def pid_file(pid)
    @options[:pid_file] = pid
  end

  def pool(name, &blk)
    @pool = name.to_sym
    options = @options.dup
    yield
    @configs[@pool] = Daemonizer::Config.new(@pool, @options)
  rescue Daemonizer::Config::ConfigError => e
    puts "* Error in pool \"#{@pool}\": #{e.to_s}. Skipping..."
  ensure
    @options = options
    @pool = nil
  end
end
