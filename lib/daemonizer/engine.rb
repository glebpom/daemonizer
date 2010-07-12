module Daemonizer
  class Engine
    attr_reader :config

    def initialize(config, debug = false)
      @config = config
    end
    
    def logger
      @config.logger
    end

    def start!
      @pm = ProcessManager.new(@config)

      init_block = Proc.new do
        begin
          @pm.start_workers do |process_id| 
            @config.handler.worker_id = process_id
            @config.handler.workers_count = @config.workers
            @config.handler.after_init
          end
        rescue Exception => e
          log_error(e)
        end
      end

      begin
        if @config.cow_friendly
          if GC.respond_to?(:copy_on_write_friendly=)
          	GC.copy_on_write_friendly = true
          	logger.info "Enabling COW-friendly feature"
          else
          	logger.info "COW-friendly feature is not supported by currently used ruby version"
          end
        end
        @config.handler.logger = logger        
        @config.handler.before_init(init_block)
      rescue Exception => e
        log_error(e)
      end
      # Start monitoring loop
      
      setup_signals
      @pm.monitor_workers
    end

    def debug!
      outputter = Outputter.stdout
      outputter.formatter = PatternFormatter.new :pattern => "%d - %l %g - %m"
      logger.outputters = outputter

      init_block = Proc.new do
        begin
          @config.handler.worker_id = 1
          @config.handler.workers_count = 1
          @config.handler.after_init
        rescue Exception => e
          log_error(e)
        end
      end

      begin
        @config.handler.logger = logger        
        @config.handler.before_init(init_block)
      rescue Exception => e
        log_error(e)
      end
    end
    
    def log_error(e)
      logger.fatal e.to_s
      logger.fatal "#{e.class}: #{e}\n" + e.backtrace.join("\n")
    end

    private
      def setup_signals
        stop = proc {
          @config.logger.info "Received a signal... stopping..."
          @pm.start_shutdown!
        }

        trap('TERM', stop)
        trap('INT', stop)
        trap('EXIT', stop)
      end

  end
end
