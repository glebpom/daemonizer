module Daemonizer
  class DslError < StandardError; end

  class Dsl
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
      @configs[@pool] = Config.new(@pool, @options)
    rescue Config::ConfigError => e
      puts "* Error in pool \"#{@pool}\": #{e.to_s}. Skipping..."
    ensure
      @options = options
      @pool = nil
    end
  end
end
