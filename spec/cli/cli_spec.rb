require "spec_helper"

describe "daemonizer with simple Daemonfile" do

  before :each do
    @pid_file = "#{tmp_dir}/test.pid"

    daemonfile <<EOF
pool :test do
  workers 1
  poll_period 5
  log_file "test.log"
  pid_file "#{@pid_file}"

  prepare do |block|
    block.call
  end

  start do |worker_id, workers_count|
    trap("TERM") { exit 0; }
  end
end

EOF
  end

  describe "on not started repository" do
    describe "on call stats" do
      before(:each) do
        daemonizer :stats
      end

      it "should return valid text" do
        @out.should match(/It seems like pool 'test' is not running/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end
    end

    describe "on call start" do
      before(:each) do
        daemonizer :start
      end

      after(:each) do
        daemonizer :stop
      end

      it "should print info about starting pool" do
        @out.should match(/test: Starting pool/)
        @out.should match(/test: successfully started/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_file).should == true
      end
    end
  end
end