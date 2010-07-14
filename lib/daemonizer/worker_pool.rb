module Daemonizer
  class WorkerPool
    attr_reader :name

    def initialize(name, pm, &blk)
      @name = name
      @pm = pm
      @worker_block = blk
      @workers = []
    end

    def shutdown?
      @pm.shutdown?
    end

    def start_workers(number)
      Daemonizer.logger.debug "Creating #{number} workers for #{name} pool..."
      number.times do |i|
        @workers << Worker.new(name, @pm, i+1, &@worker_block)
      end
    end

    def check_workers
      Daemonizer.logger.debug "Checking loop #{name} workers..."
      @workers.each do |worker|
        next if worker.running? || worker.shutdown?
        Daemonizer.logger.warn "Worker #{worker.name} is not running. Restart!"
        worker.run
      end
    end

    def wait_workers
      running = 0
      @workers.each do |worker|
        next unless worker.running?
        running += 1
        Daemonizer.logger.debug "Worker #{name} is still running (#{worker.pid})"
      end
      return running
    end

    def stop_workers(force)
      Daemonizer.logger.debug "Stopping #{name} pool workers..."
      @workers.each do |worker|
        next unless worker.running?
        worker.stop(force)
      end
    end
  end
end
