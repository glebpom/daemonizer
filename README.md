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
compatible with EventMachine, Rails and any other Ruby frameworks.


Feature List
------------
                                                                              
**1. Daemonfile (similar to Gemfile, Rakefile)** as a configuration file. It is 
possible to describe different background pools there.
                                                                              
**2. Monitoring**: If child is found dead it will be immediately 
restored
                                                                              
**3. Logging**

Installing
----------

To install Daemonizer, use the following command:

    $ gem install daemonizer
    
(Add `sudo` if you're installing under a POSIX system as root)                                                                              

Usage
-----

**Demfile example:**

    workers 2
    poll_period 5

    pool :daemonizer do
      workers 4
      log_file "log/daemonizer.log" #relative to Demfile
  
      prepare do |logger, block|
        block.call
      end
  
      start do |logger, worker_id, workers_count|
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

    settings_group do 
      before_start do |logger, worker_id, workers_count|
        #reconnect to db, etc.
      end

      #simple string option
      set_option :author, "Gleb Pomykalov"

      pool :new_daemonizer do
        workers 4
        log_file "log/daemonizer.log" #relative to Demfile

        handler MyBackgroundSolution::DaemonizerHandler
      
        not_cow_friendly #disable Copy-On-Write friendly (enabled by default)

        #automatically-parsed option by daemonizer
        set_option :queue do |worker_id, worker_count|  
          "queue_#{worker_id}"
        end
            
        #lambda-option (transparent for daemonizer, fully processed by handler)
        set_option :on_error, lambda { |object| object.logger.fatal "epic fail"}
      end


      pool :new_daemonizer2 do
        workers 4
        log_file "log/daemonizer2.log" #relative to Demfile

        handler MyBackgroundSolution::DaemonizerHandler
              
        not_cow_friendly #disable Copy-On-Write friendly (enabled by default)

        #automatically-parsed option by daemonizer
        set_option :queue do |worker_id, worker_count|  
          "another_queue_#{worker_id}"
        end
        
        after_prepare do |logger|
          require 'something'
        end
        
        #lambda-option (transparent for daemonizer, fully processed by handler)
        set_option :on_error, lambda { |object| object.logger.fatal "epic fail"}
      end
    end

**Handler example**

    module MyBackgroundSolution
      class DaemonizerHandler < Daemonizer::Handler
        def prepare(block)
          require File.join(Daemonizer.root, '/config/environment') #Require rails
          require 'my_background_solution/worker' #Require our code
          super #now we are ready to fork
        end

        def start 
          #we are in worker process
          logger.info "Starting cycle. We are number #{worker_id} from #{workers_count}"
          logger.info "Options - #{option(:queue)}" #We can get option :queue, which is set with set_option in pool configuration
          worker = Worker.new
          worker.run
          logger.info "Ending cycle"
        end
      end
    end
    
Who are the authors
-------------------

This gem has been created in qik.com for our internal use and then 
the sources were opened for other people to use. All the code in this package 
has been developed by Gleb Pomykalov. As for the first versions, it was mostly based
 on [http://github.com/kovyrin/loops](loops) code written by Alexey Kovyrin. Now
most of it is heavily refactored.  The gem is released under the MIT license. For
more details, see the LICENSE file.
