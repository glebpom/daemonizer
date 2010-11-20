require "spec_helper"

class OptionsSpecHandler < Daemonizer::Handler
  def initialize(*args)
    @worker_id = 1
    @workers_count = 1
    super
  end

  def prepare(starter, &block)

  end

  def start
    self
  end
end

describe "pool options in Daemonizer::Config" do
  context "with name and value" do
    before :each do
      @handler = Daemonizer::Engine.new(Daemonizer::Config.new(:pool, {
                :workers => 1,
                :pid_file =>"#{tmp_dir}/test1.pid",
                :log_file =>"#{tmp_dir}/test1.log",
                :handler_options => {
                    :simple => Daemonizer::Option.new(:simple, "simple_value"),
                    :lambda => Daemonizer::Option.new(:lambda, lambda { "lambda_value" }),
                    :block => Daemonizer::Option.new(:block, lambda { "block_value" }, true)
                 },
                :handler => OptionsSpecHandler
      })).run_start_with_callbacks
    end

    it "should return simple option" do
      @handler.option(:simple).should == "simple_value"
    end

    it "should return lambda value" do
      @handler.option(:lambda).should be_kind_of(Proc)
    end

    it "should return simple option" do
      @handler.option(:block).should == "block_value"
    end

  end

end

describe Daemonizer::Option do
  context "with auto_eval set to true" do
    context "and not lambda value" do
      it do
        lambda {
          Daemonizer::Option.new(:option, "not_lambda", true)
        }.should raise_error(Daemonizer::Option::OptionError)
      end
    end

    context "and lambda value" do
      context "and handler is not defined" do
        it do
          lambda {
            Daemonizer::Option.new(:option, lambda { "lambda" }, true).value
          }.should raise_error(Daemonizer::Option::OptionError)
        end
      end
      context "and handler defined" do
        it do
          Daemonizer::Option.new(:option, lambda { "lambda" }, true).
            value(OptionsSpecHandler.new).
            should == "lambda"
        end
      end
    end
  end

  context "with auto_eval set to false" do
    context "and not lambda value" do
      it do
        Daemonizer::Option.new(:option, "simple").value.should == "simple"
      end
    end

    context "and lambda value" do
      it do
        Daemonizer::Option.new(:option, lambda { "lambda" }).value.
          should be_kind_of(Proc)
      end
    end
  end


end
