require "spec_helper"

describe "daemonzier after start" do

  before :each do
    @pid_files = simple_daemonfile(
             :name => :test1,
             :pid_file =>"#{tmp_dir}/test1.pid",
             :on_start => "loop { sleep 1 }",
             :workers => 3)
    daemonizer :start
  end

  after :each do
    daemonizer :stop
  end

  it "should create 3 forks" do
    #should sleep here
    sleep 3
    children_count(File.read(@pid_files[0]).chomp).should == 3
  end

end
