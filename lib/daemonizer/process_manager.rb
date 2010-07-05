module Daemonizer
  class ProcessManager
    def initialize(config)
      @worker_pools = {}
      @shutdown = false
      @config = config
    end
    
    def logger
      @config.logger
    end

    def start_workers(&blk)
      raise ArgumentError, "Need a worker block!" unless block_given?

      @worker_pools[@config.pool] = WorkerPool.new(@config.pool, self, @config.engine, &blk)
      @worker_pools[@config.pool].start_workers(@config.workers)
    end

    def monitor_workers
      setup_signals

      logger.debug 'Starting workers monitoring code...'
      loop do
        logger.debug "Checking workers' health..."
        @worker_pools.each do |name, pool|
          break if shutdown?
          pool.check_workers
        end

        break if shutdown?
        logger.debug "Sleeping for #{@config.poll_period} seconds..." 
        sleep(@config.poll_period)
      end
    ensure
      logger.debug "Workers monitoring loop is finished, starting shutdown..."
      # Send out stop signals
      stop_workers(false)

      # Wait for all the workers to die
      unless wait_for_workers(10)
        logger.warn "Some workers are still alive after 10 seconds of waiting. Killing them..."
        stop_workers(true)
        wait_for_workers(5)
      end
    end

    def setup_signals
      # Zombie reapers
      trap('CHLD') {}
      trap('EXIT') {}
    end

    def wait_for_workers(seconds)
      seconds.times do
        logger.debug "Shutting down... waiting for workers to die (we have #{seconds} seconds)..."
        running_total = 0

        @worker_pools.each do |name, pool|
          running_total += pool.wait_workers
        end

        if running_total.zero?
          logger.debug "All workers are dead. Exiting..."
          return true
        end

        logger.debug "#{running_total} workers are still running! Sleeping for a second..."
        sleep(1)
      end

      return false
    end

    def stop_workers(force = false)
      # Set shutdown flag
      logger.debug "Stopping workers#{force ? ' (forced)' : ''}..."

      # Termination loop
      @worker_pools.each do |name, pool|
        pool.stop_workers(force)
      end
    end

    def shutdown?
      @shutdown
    end

    def start_shutdown!
      logger.debug "Starting shutdown (shutdown flag set)..."
      @shutdown = true
    end
  end
end
