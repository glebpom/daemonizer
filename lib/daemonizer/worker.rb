module Daemonizer
  class Worker
    attr_reader :name
    attr_reader :process_name
    attr_reader :pid

    def initialize(name, pm, worker_id, &blk)
      raise ArgumentError, "Need a worker block!" unless block_given?

      @name = name
      @pm = pm
      @worker_block = blk
      @worker_id = worker_id
      @process_name = "#{@name} worker: instance #{@worker_id}"
    end

    def shutdown?
      @pm.shutdown?
    end

    def run
      return if shutdown?
      Daemonizer.logger.info "Forking..."
      @pid = Kernel.fork do
        Dir.chdir '/'
        File.umask 0000

        STDIN.reopen '/dev/null'
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen STDOUT

        setup_signals

        @pid = Process.pid
        Daemonizer.reopen_log_file
        Daemonizer.logger_context = "#{@pid}/#{@worker_id}"

        Daemonizer.logger.info "Log file reopened after fork"
        normal_exit = false
        begin
          $0 = "#{@process_name}\0"
          @worker_block.call(@worker_id)
          normal_exit = true
          exit(0)
        rescue Exception => e
          message = SystemExit === e ? "exit(#{e.status})" : e.to_s
          if SystemExit === e and e.success?
            if normal_exit
              Daemonizer.logger.info("Worker finished: normal return")
            else
              Daemonizer.logger.error("Worker exited: #{message} at #{e.backtrace.first}")
            end
          else
            Daemonizer.logger.error("Worker exited with error: #{message}\n  #{e.backtrace.join("\n  ")}")
          end
          Daemonizer.logger.debug("Terminating #{@name} worker: #{@pid}")
        end
      end
    rescue Exception => e
      Daemonizer.logger.error("Exception from worker: #{e} at #{e.backtrace.first}")
    end

    def running?(verbose = false)
      return false unless @pid
      begin
        Process.waitpid(@pid, Process::WNOHANG)
        res = Process.kill(0, @pid)
        Daemonizer.logger.debug("KILL(#{@pid}) = #{res}") if verbose
        return true
      rescue Errno::ESRCH, Errno::ECHILD, Errno::EPERM => e
        Daemonizer.logger.error("Exception from kill: #{e} at #{e.backtrace.first}") if verbose
        return false
      end
    end

    def stop(force = false)
      begin
        sig = force ? 'SIGKILL' : 'SIGTERM'
        Daemonizer.logger.debug("Sending #{sig} to ##{@pid}")
        Process.kill(sig, @pid)
      rescue Errno::ESRCH, Errno::ECHILD, Errno::EPERM=> e
        Daemonizer.logger.error("Exception from kill: #{e} at #{e.backtrace.first}")
      end
    end

    def send_signal(signal)
      Process.kill(signal, @pid)
    end

    private

    def setup_signals
      trap('SIGHUP') do
        Daemonizer.reopen_log_file
      end
    end
  end
end
