module Daemonizer
  class Engine
    attr_reader :config

    def initialize(config)
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

    def run_prepare_with_callbacks(&block)
      run_callback :before_prepare, @config.pool
      Daemonizer.logger.info "Workers count is #{@config.workers}"
      @config.handler.prepare(block) do
        run_callback :after_prepare, @config.pool
      end
    end

    def run_start_with_callbacks
      run_callback :before_start, @config.pool, @config.handler.worker_id, @config.handler.workers_count
      @config.handler.start
    end

    def start!
      @pm = ProcessManager.new(@config)

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
        run_prepare_with_callbacks do
          begin
            @pm.start_workers do |process_id|
              @config.handler.worker_id = process_id
              @config.handler.workers_count = @config.workers
              run_start_with_callbacks
            end
          rescue Exception => e
            log_error(e)
          end
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

      begin
        run_prepare_with_callbacks do
          begin
            @config.handler.worker_id = 1
            @config.handler.workers_count = 1
            run_start_with_callbacks
          rescue Exception => e
            log_error(e)
          end
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
