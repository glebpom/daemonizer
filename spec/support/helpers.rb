module Spec
  module Helpers
    def reset!
      FileUtils.rm_rf(app_root)
      FileUtils.mkdir_p(app_root)
    end

    def in_app_root(&blk)
      Dir.chdir(app_root, &blk)
    end

    def daemonizer(cmd)
      sys_exec File.join(gem_root, 'bin/daemonizer') + " " + cmd.to_s
    end

    def daemonfile(code)
      File.open(File.join(app_root, "Daemonfile"), 'w') do |f|
        f.puts code
      end
    end

    attr_reader :out, :err, :exitstatus

    def sys_exec(cmd, expect_err = false)
      Open3.popen3(cmd.to_s) do |stdin, stdout, stderr|
        @in_p, @out_p, @err_p = stdin, stdout, stderr

        yield @in_p if block_given?
        @in_p.close

        @out = @out_p.read_available_bytes.strip
        @err = @err_p.read_available_bytes.strip
      end

      puts @err unless expect_err || @err.empty? || !$show_err
      @out
    end

    extend self
  end
end
