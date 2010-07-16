module Daemonizer
  class Handler
    attr_accessor :worker_id
    attr_accessor :workers_count
    attr_accessor :logger
    
    def initialize(handler_options = {})
      @handler_options = handler_options
    end
    
    def prepare(starter, &block)
      if block_given?
        yield
      end
      starter.call
    end
    
    def option(key)
      if handler_option = @handler_options[key.to_sym]
        handler_option.value(self)
      else
        nil
      end
    end
  end
  
  class FakeHandler < Handler
    def initialize(prepare, start, handler_options = {})
      @prepare = prepare
      @start = start
      super(handler_options)
    end
    
    def prepare(starter, &block)
      if @prepare
        @prepare.call(Daemonizer.logger, block)
      else
        super
      end
    end
        
    def start
      @start.call(Daemonizer.logger, @worker_id, @workers_count)
    end
  end
end
