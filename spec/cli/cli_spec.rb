require "spec_helper"
describe "daemonizer with simple Daemonfile" do

  before :each do
    daemonfile <<EOF
pool :test do
  workers 1
  poll_period 5
  log_file "test.log"
  pid_file "test.pid"

  prepare do |block|
    block.call
  end

  start do |worker_id, workers_count|
  end
end

EOF
  end

  describe "on not started repository" do
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

end