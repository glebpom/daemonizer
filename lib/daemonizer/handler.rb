module Daemonizer
  class Handler
    attr_accessor :worker_id
    attr_accessor :workers_count
    attr_accessor :logger
    
    def initialize(options = {})
      @options = options
    end
    
    def before_init(block)
      block.call
    end
    
    def option(key)
      if option = @options[key.to_sym] and option.is_a?(Proc)
        option.call(@worker_id, @workers_count)
      else
        option
      end
    end
  end
  
  class FakeHandler < Handler
    def initialize(before_init, after_init, options = {})
      @before_init = before_init
      @after_init = after_init
      super(options)
    end
    
    def before_init(block)
      if @before_init
        @before_init.call(@logger, block)
      else
        super
      end
    end
        
    def after_init
      @after_init.call(@logger, @worker_id, @workers_count)
    end
  end
end
