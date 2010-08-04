module Daemonizer
  class WorkerPool
    MONITOR_VALUE = [:vm_size, :private_dirty_rss, :rss]
    
    attr_reader :name
    attr_reader :stats

    def initialize(name, pm, &blk)
      @name = name
      @pm = pm
      @worker_block = blk
      @workers = []
      @stats = ::SimpleStatistics::DataSet.new
    end
    
    def find_worker_by_name(name)
      @workers.detect do |w|
        w.process_name.to_s == name.to_s
      end
    end

    def shutdown?
      @pm.shutdown?
    end

    def start_workers(number)
      Daemonizer.logger.debug "Creating #{number} workers for #{name} pool..."
      number.times do |i|
        worker = Worker.new(name, @pm, i+1, &@worker_block)
        @workers << worker
        @stats.add_data(worker.process_name)
        Daemonizer.logger.info "Gathering data for #{worker.name}"    
      end
    rescue Exception => e
      Daemonizer.logger.info "Result - #{e.inspect}"
    end

    def check_workers
      Daemonizer.logger.debug "Checking loop #{name} workers..."

      Daemonizer::Stats::MemoryStats.new(self).find_workers.each do |p|
        worker_name = p.name
        MONITOR_VALUE.each do |value|
          @stats.tick(value)
          @stats[worker_name][value].add_probe(p.send(value))
        end
      end
      
      @workers.each do |worker|
        unless worker.running? || worker.shutdown?
          Daemonizer.logger.warn "Worker #{worker.name} is not running. Restart!"
          @stats.add_data(worker.process_name)
          MONITOR_VALUE.each do |v|
            @stats[worker.process_name].reset(v)
          end
          worker.run
        end
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
