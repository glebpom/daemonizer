module Daemonizer
  class ProcessManager
    def initialize(config)
      @shutdown = false
      @config = config
    end


    def start_workers(&blk)
      raise ArgumentError, "Need a worker block!" unless block_given?
      Daemonizer.logger.info "starting all workers"
      @pool = WorkerPool.new(@config.pool, self, &blk)
      @pool.start_workers(@config.workers)
    end

    def monitor_workers
      setup_signals

      Daemonizer.logger.debug 'Starting workers monitoring code...'
      loop do
        Daemonizer.logger.debug "Checking workers' health..."
        break if shutdown?
        @pool.check_workers
        
        @config.on_poll.each do |on_poll|
          on_poll.call(@pool)
        end

        break if shutdown?
        Daemonizer.logger.debug "Sleeping for #{@config.poll_period} seconds..." 
        sleep(@config.poll_period)
      end
    rescue Exception => e
      Daemonizer.logger.fatal "Monitor error: #{e.to_s}\n  #{e.backtrace.join("\n  ")}"
      raise
    ensure
      Daemonizer.logger.debug "Workers monitoring loop is finished, starting shutdown..."
      # Send out stop signals
      stop_workers(false)

      # Wait for all the workers to die
      unless wait_for_workers(10)
        Daemonizer.logger.warn "Some workers are still alive after 10 seconds of waiting. Killing them..."
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
        Daemonizer.logger.debug "Shutting down... waiting for workers to die (we have #{seconds} seconds)..."
        running_total = @pool.wait_workers

        if running_total.zero?
          Daemonizer.logger.debug "All workers are dead. Exiting..."
          return true
        end

        Daemonizer.logger.debug "#{running_total} workers are still running! Sleeping for a second..."
        sleep(1)
      end

      return false
    end

    def stop_workers(force = false)      
      # Set shutdown flag
      Daemonizer.logger.debug "Stopping workers#{force ? ' (forced)' : ''}..."

      # Termination loop
      @pool.stop_workers(force)
    end

    def shutdown?
      @shutdown
    end

    def start_shutdown!
      Daemonizer.logger.debug "Starting shutdown (shutdown flag set)..."
      @shutdown = true
    end
  end
end
