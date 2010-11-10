require "spec_helper"

describe "with Daemonfile and daemonzier is not started " do

  before :each do
    @pid_files = simple_daemonfile({:name => :test1, :pid_file =>"#{tmp_dir}/test1.pid"}, {:name => :test2, :pid_file => "#{tmp_dir}/test2.pid"})
  end

  describe "on call 'stats'" do
    before(:each) do
      daemonizer :stats
    end

    it "should return valid text" do
      @out.should match(/It seems like pool 'test1' is not running/)
      @out.should match(/It seems like pool 'test2' is not running/)
    end

    it "should not return anything to stderr" do
      @err.should == ''
    end
  end

  describe "on call 'start'" do
    describe "with all pools" do
      before(:each) do
        daemonizer :start
      end

      after(:each) do
        daemonizer :stop
      end

      it "should print info about starting 2 pools" do
        @out.should match(/test1: Starting pool/)
        @out.should match(/test1: successfully started/)
        @out.should match(/test2: Starting pool/)
        @out.should match(/test2: successfully started/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_files[0]).should be_true
        daemonizer_runned?(@pid_files[1]).should be_true
      end
    end

    describe "with specific pool" do
      before(:each) do
        daemonizer "start test1"
      end

      after(:each) do
        daemonizer "stop test1"
      end

      it "should print info about starting 2 pools" do
        @out.should match(/test1: Starting pool/)
        @out.should match(/test1: successfully started/)
        @out.should_not match(/test2: Starting pool/)
        @out.should_not match(/test2: successfully started/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_files[0]).should be_true
        daemonizer_runned?(@pid_files[1]).should be_false
      end
    end
  end

  describe "on call 'stop'" do
    describe "with all pools" do

      before(:each) do
        daemonizer :stop
      end

      it "should return valid text" do
        @out.should match(/test1: No pid file or a stale pid file!/)
        @out.should match(/test2: No pid file or a stale pid file!/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end
    end

    describe "with specific pool" do

      before(:each) do
        daemonizer "stop test1"
      end

      it "should return valid text" do
        @out.should match(/test1: No pid file or a stale pid file!/)
        @out.should_not match(/test2: No pid file or a stale pid file!/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end
    end

  end
end
