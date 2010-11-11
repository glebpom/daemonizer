require "spec_helper"

describe "Evaluating pool settings through dsl" do
  before :each do
    @dsl = Daemonizer::Dsl.evaluate(<<-EOF)
      poll_period 10

      pool "pool1" do
        workers 1

        not_cow_friendly
      end
      pool "pool2" do
        workers 2
        poll_period 2
      end
    EOF

    @configuration = @dsl.configs
  end

  it "should create 2 pool record" do
    @configuration.size.should == 2
  end

  it "should set parameters on pools isolated" do
    @configuration[:pool1].keys.should include(:workers, :poll_period, :cow_friendly)
    @configuration[:pool2].keys.should include(:workers, :poll_period)
    @configuration[:pool2].keys.should_not include(:cow_friendly)
  end

  it "should correctly inherit parameters from top level" do
    @configuration[:pool1][:poll_period].should == 10
    @configuration[:pool2][:poll_period].should == 2
  end

  it "should process pool definition on call Daemonizer::Dsl#process" do
    pool_config = Daemonizer::Config
    pool_config.should_receive(:new).with(:pool2, equal(@configuration[:pool2])).once
    pool_config.should_receive(:new).with(:pool1, equal(@configuration[:pool1])).once
    @processed_config = @dsl.process
  end
end
