module Spec
  module Processes
    def children_count(parent_pid)
     `ps -lx`[1..-1].to_a.count do |l|
        uid, pid, ppid, = l.lstrip.split(/\s{1,}/)
        ppid.to_i == parent_pid.to_i
      end
    end

    extend self
  end
end



