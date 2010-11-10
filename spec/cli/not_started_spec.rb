require "spec_helper"

describe "daemonizer with mass cli operations Daemonfile" do

  before :each do
    @pid_files = ["#{tmp_dir}/test1.pid", "#{tmp_dir}/test2.pid"]

    daemonfile <<EOF
pool :test do
  workers 1
  poll_period 5
  log_file "test.log"
  pid_file "#{@pid_files[0]}"

  prepare do |block|
    block.call
  end

  start do |worker_id, workers_count|
    trap("TERM") { exit 0; }
  end
end

pool :test2 do
  workers 1
  poll_period 5
  log_file "test.log"
  pid_file "#{@pid_files[1]}"

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
        @out.should match(/It seems like pool 'test2' is not running/)
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

      it "should print info about starting pool2" do
        @out.should match(/test: Starting pool/)
        @out.should match(/test: successfully started/)
        @out.should match(/test2: Starting pool/)
        @out.should match(/test2: successfully started/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_files[0]).should == true
        daemonizer_runned?(@pid_files[1]).should == true
      end
    end

    describe "on call stop" do
      before(:each) do
        daemonizer :stop
      end

      it "should print info about starting pool2" do
        @out.should match(/test: Starting pool/)
        @out.should match(/test: successfully started/)
        @out.should match(/test2: Starting pool/)
        @out.should match(/test2: successfully started/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_files[0]).should == true
        daemonizer_runned?(@pid_files[1]).should == true
      end
    end


  end
end