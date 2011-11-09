require "spec_helper"

describe "with Daemonfile and daemonzier is already started " do

  before :each do
    @pid_files = simple_daemonfile({:name => :test1, :pid_file =>"#{tmp_dir}/test1.pid"}, {:name => :test2, :pid_file => "#{tmp_dir}/test2.pid"})
    daemonizer "start"
  end

  after :each do
    daemonizer "stop"
  end

  describe "on call 'stats'" do
    before(:each) do
      daemonizer :stats
    end

    it "should return valid text" do
      @out.should match(/test1 processes/)
      @out.should match(/test2 processes/)
    end

    it "should not return anything to stderr" do
      @err.should == ''
    end
  end

  describe "on call 'logrotate'" do
    before(:each) do
      daemonizer :logrotate
    end

    it "should return valid text" do
      @out.should match(/test1: log file reopened/)
      @out.should match(/test2: log file reopened/)
    end

    it "should not return anything to stderr" do
      @err.should == ''
    end
  end

  describe "on call 'start'" do
    describe "with all pools" do
      before(:each) do
        daemonizer 'start'
      end

      it "should print info about starting 2 pools" do
        @out.should match(/test1: Can't start, another process exists!/)
        @out.should match(/test2: Can't start, another process exists!/)
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

      it "should print info about starting 2 pools" do
        @out.should match(/test1: Can't start, another process exists!/)
        @out.should_not match(/test2/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end

      it "should run daemonizer processes" do
        daemonizer_runned?(@pid_files[0]).should be_true
        daemonizer_runned?(@pid_files[1]).should be_true
      end
    end

  end

  describe "on call 'stop'" do
    describe "with all pools" do

      before(:each) do
        daemonizer "stop"
      end

      it "should return valid text" do
        @out.should match(/test1: Killing the process/)
        @out.should match(/test2: Killing the process/)
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
        @out.should match(/test1: Killing the process/)
        @out.should_not match(/test2: Killing the process/)
      end

      it "should not return anything to stderr" do
        @err.should == ''
      end
    end

  end
end
