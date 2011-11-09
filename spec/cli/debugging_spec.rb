require "spec_helper"

describe "with Daemonfile and daemonzier is in 'debug' mode" do

  before :each do
    @pid_files = simple_daemonfile(
             :name => :test1,
             :pid_file =>"#{tmp_dir}/test1.pid",
             :on_prepare => "Daemonizer.logger.info \"test1: executed prepare\"",
             :on_start => "Daemonizer.logger.info \"test1: executed start\"")
  end

  describe "with all pools" do

    before(:each) do
      daemonizer :debug
    end

    it "should return valid text" do
      @out.should match(/You should supply pool_name to debug/)
    end

    it "should not return anything to stderr" do
      @err.should == ''
    end
  end

  describe "with specific pool" do

    before(:each) do
      daemonizer "debug test1"
    end

    it "should return valid text" do
      @out.should match(/test1: executed prepare/)
      @out.should match(/test1: executed start/)
    end

    it "should not return anything to stderr" do
      @err.should == ''
    end
  end


end
