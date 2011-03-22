require "spec_helper"

describe "daemonzier after start" do

  before :each do
    @pid_files = simple_daemonfile(
             :name => :test1,
             :pid_file =>"#{tmp_dir}/test1.pid",
             :on_start => "loop { sleep 1 }",
             :workers => 3,
             :poll_period => 1)
    daemonizer :start
    sleep 5
  end

  after :each do
    daemonizer :stop
  end

  it "should create 3 forks" do
    children_count(pid(@pid_files[0])).should == 3
  end

  describe "after one worker died" do
    before :each do
      Process.kill("KILL", children_pids(pid(@pid_files[0])).first.to_i)
      sleep 5
    end

    it "should restore it" do
      children_count(pid(@pid_files[0])).should == 3
    end
  end

end
