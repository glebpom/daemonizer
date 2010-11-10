module Spec
  module DaemonfileFactory
    def simple_daemonfile(*pools)
      code = ""
      pid_files = pools.map do |pool|
        if pool[:exit_on_start]
        end
        code << <<EOF
pool :#{pool[:name]} do
  workers 1
  poll_period 5
  log_file "test.log"
  pid_file "#{pool[:pid_file]}"

  prepare do |block|
    #{pool[:on_prepare]}
    block.call
  end

  start do |worker_id, workers_count|
     #{pool[:on_start]}
    trap("TERM") { exit 0; }
  end
end

EOF
        pool[:pid_file]
      end
      daemonfile code
      pid_files
    end
  end
end
