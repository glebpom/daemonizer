Daemonizer: Simple framework for creating daemons with Ruby
====================================

**Homepage**:     [http://daemonizer.org](http://daemonizer.org)   
**Git**:          [http://github.com/glebpom/daemonizer](http://github.com/glebpom/daemonizer)   
**Author**:       Gleb Pomykalov    
**Copyright**:    2010    
**License**:      MIT License    
**Status**:       alpha    

Synopsis
--------

Daemonizer is a simple ruby framework to create custom daemons. It is fully 
compatible with EventMachine, Rails and any other Ruby frameworks. Two workers
type supported - forked and threaded.


Feature List
------------
                                                                              
**1. Demfile (similar to Gemfile, Rakefile)** as a configuration file. It is 
possible to describe different background pools there.

**2. Two engines**: :thread and :fork. (thread is currently broken)
                                                                              
**3. Monitoring**: If child is found dead it will be immediately 
restored
                                                                              
**4. Logging** (via log4r)

Installing
----------

To install Daemonizer, use the following command:

    $ gem install daemonizer
    
(Add `sudo` if you're installing under a POSIX system as root)                                                                              

Usage
-----

**1. Demfile example:**

    engine :fork 
    workers 2

    pool :daemonizer do
      workers 4
      poll_period 5
      log_file "log/daemonizer.log" #relative to Demfile
  
      before_init do |logger, block|
        block.call
      end
  
      after_init do |logger, worker_id, workers_count|
        logger.info "Started #{worker_id} from #{workers_count}"
    
        exit = false
    
        stop = proc {
          exit = true
        }

        trap('TERM', stop)
        trap('INT', stop)
        trap('EXIT', stop)
    
        loop do
          break if exit
          logger.info "Ping #{worker_id}"
          sleep 10
        end
    
        true
      end
    end

    pool :new_daemonizer do
      workers 4
      poll_period 5
      log_file "log/daemonizer.log" #relative to Demfile

      handler ::AsyncObserver::DaemonizerHandler
  
      set_option :queue, lambda { |worker_id, worker_count| "queue_#{worker_id}"}
    end
