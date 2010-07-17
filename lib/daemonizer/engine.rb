module Daemonizer
  class Engine
    attr_reader :config

    def initialize(config, debug = false)
      @config = config
      Daemonizer.logger_context = "#{Process.pid}/monitor"
    end
    
    def run_callback(callback, *args)
      if callbacks = @config.callbacks[callback.to_sym] and callbacks.any?
        Daemonizer.logger.info "Running :#{callback} callbacks"
        callbacks.each do |callback|
          callback.call(*args)
        end
      end
    end
    
    def start!
      @pm = ProcessManager.new(@config)

      init_block = Proc.new do
        begin
          @pm.start_workers do |process_id|
            @config.handler.worker_id = process_id
            @config.handler.workers_count = @config.workers
            run_callback(:before_start, Daemonizer.logger, process_id, @config.workers)
            @config.handler.start
          end
        rescue Exception => e
          log_error(e)
        end
      end

      begin
        if @config.cow_friendly
          if GC.respond_to?(:copy_on_write_friendly=)
          	GC.copy_on_write_friendly = true
          	Daemonizer.logger.info "Enabling COW-friendly feature"
          else
          	Daemonizer.logger.info "COW-friendly feature is not supported by currently used ruby version"
          end
        end
        @config.handler.logger = Daemonizer.logger
        run_callback(:before_prepare, Daemonizer.logger)
        Daemonizer.logger.info "Workers count is #{config.workers}"
        @config.handler.prepare(init_block) do
          run_callback(:after_prepare, Daemonizer.logger)
        end
      rescue Exception => e
        log_error(e)
      end
      # Start monitoring loop
      
      setup_signals
      @pm.monitor_workers
    end

    def debug!
      Daemonizer.init_console_logger('console')
      @config.handler.logger = Daemonizer.logger
      
      init_block = Proc.new do
        begin
          @config.handler.worker_id = 1
          @config.handler.workers_count = 1
          run_callback(:before_start, Daemonizer.logger, 1, 1)
          @config.handler.start
        rescue Exception => e
          log_error(e)
        end
      end

      begin
        run_callback(:before_prepare, Daemonizer.logger)
        @config.handler.prepare(init_block) do
          run_callback(:after_prepare, Daemonizer.logger)
        end
      rescue Exception => e
        log_error(e)
      end
    end
    
    def log_error(e)
      Daemonizer.logger.fatal e.to_s
      Daemonizer.logger.fatal "#{e.class}: #{e}\n" + e.backtrace.join("\n")
    end

    private
      def setup_signals
        stop = proc {
          Daemonizer.logger.info "Received a signal... stopping..."
          @pm.start_shutdown!
        }

        trap('TERM', stop)
        trap('INT', stop)
        trap('EXIT', stop)
      end

  end
end
