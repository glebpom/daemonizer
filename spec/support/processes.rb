module Spec
  module Processes
    def children_count(parent_pid)
      children_pids(parent_pid).count
    end

    def children_pids(parent_pid)
      `ps -lx`.to_a[1..-1].map do |l|
        _, pid, ppid, = l.lstrip.split(/\s{1,}/)
        ppid.to_i == parent_pid.to_i ? pid : nil
      end.compact.uniq
    end

    def pid(pid_file)
      File.read(pid_file).chomp
    end

    extend self
  end
end



