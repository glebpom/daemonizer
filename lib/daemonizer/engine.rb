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
            @config.after_init.call(logger, process_id, @config.workers)
          end
        rescue Exception => e
          logger.fatal e.to_s
        end
      end

      begin
        @config.before_init.call(@config.logger, init_block)
      rescue Exception => e
        logger.fatal e.to_s
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
          @config.after_init.call(logger, 1, 1)
        rescue Exception => e
          logger.fatal e.to_s
        end
      end

      begin
        @config.before_init.call(@config.logger, init_block)
      rescue Exception => e
        logger.fatal e.to_s
      end
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
