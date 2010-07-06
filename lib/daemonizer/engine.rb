module Daemonizer
  class Engine
    attr_reader :config

    def initialize(config)
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
          logger.fatal get_exception(e)
        end
      end

      begin
        @config.before_init.call(@config.logger, init_block)
      rescue Exception => e
        logger.fatal get_exception(e)
      end
      # Start monitoring loop
      
      setup_signals
      @pm.monitor_workers
    end

=begin
    def debug_loop!(loop_name)
      @pm = Daemonizer::ProcessManager.new(global_config, Daemonizer.logger)
      loop_config = loops_config[loop_name] || {}

      # Adjust loop config values before starting it in debug mode
      loop_config['workers_number'] = 1
      loop_config['debug_loop'] = true

      # Load loop class
      unless klass = load_loop_class(loop_name, loop_config)
        puts "Can't load loop class!"
        return false
      end

      # Start the loop
      start_loop(loop_name, klass, loop_config)
    end
=end
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
