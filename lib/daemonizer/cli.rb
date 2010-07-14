require 'thor'
require 'rubygems/config_file'

module Daemonizer  
  class CLI < Thor
    check_unknown_options!

    method_option :demfile, :type => :string, :aliases => "-D", :banner => "Path to Demfile"

    def initialize(*)
      super
      Daemonizer.demfile = options[:demfile] || "Demfile"
    end
                
    desc "start", "Start pool"
    def start(pool_name = nil)
      control_pools_loop(pool_name, "successfully started") do |pool|
        # Pid file check
        if Daemonize.check_pid(pool.pid_file)
          print_pool pool.name,  "Can't start, another process exists!"
          exit(1)
        end

        print_pool pool.name,  "Starting pool"

        app_name = "#{pool.name} monitor\0"
        
        Daemonize.daemonize(app_name)

        Dir.chdir(Daemonizer.root) # Make sure we're in the working directory

        # Pid file creation
        Daemonize.create_pid(pool.pid_file)

        # Workers processing
        engine = Engine.new(pool)
        engine.start!

        # Workers exited, cleaning up
        File.delete(pool.pid_file) rescue nil
      end
      return true
    end
    
    desc "stop", "Stop pool"
    def stop(pool_name = nil)
      control_pools_loop(pool_name, "successfully stoped") do |pool|
        STDOUT.sync = true
        unless Daemonize.check_pid(pool.pid_file)
          print_pool pool.name, "No pid file or a stale pid file!"
          exit 1
        end

        pid = Daemonize.read_pid(pool.pid_file)
        print_pool pool.name,  "Killing the process: #{pid}: "

        loop do
          Process.kill('SIGTERM', pid)
          sleep(1)
          break unless Daemonize.check_pid(pool.pid_file)
        end

        print_pool pool.name,  " Done!"
        exit(0)
      end
      return true
    end

    desc "list", "List of pools"
    def list
      puts "List of configured pools:"
      puts "" 
      Daemonizer.find_pools(nil).each do |pool|
        puts "  * #{pool.name}" 
      end
      puts ""
      return true
    end


    desc "restart", "Restart pool"
    def restart(pool_name = nil)
      invoke :stop, pool_name
      invoke :start, pool_name
    end

    desc "debug", "Debug pool (do not demonize)"
    def debug(pool_name = nil)
      puts "You should supply pool_name to debug" if pool_name.nil?
      control_pools_loop(pool_name, "execution ended", true) do |pool|
        STDOUT.sync = true
        print_pool pool.name,  "Debugging pool: "
        
        engine = Engine.new(pool)
        engine.debug!
        
        print_pool pool.name,  " Done!"
        exit(0)
      end
      return true    
    end
    
  private
    def control_pools_loop(pool_name, message = nil, debug = false, &block)
      Daemonizer.find_pools(pool_name).each do |pool|
        Process.fork do
          if debug
            Daemonizer.init_console_logger(pool.name.to_s)
          else
            Daemonizer.init_logger(pool.name.to_s, pool.log_file)
          end
          yield(pool)
        end
        Process.wait
        if $?.exitstatus == 0 and message
          print_pool pool.name, message 
        end
      end
    end
    
    def print_pool(pool_name, message)
      puts "#{pool_name}: #{message}"
    end
  end
end
