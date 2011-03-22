require "spec_helper"

class OptionsSpecHandler < SpecHandler; end

describe "set_option in Daemonfile" do
  it "should initialize simple setting correctly" do
    Daemonizer::Option.expects(:new).with(:simple, "simple_value").once
    Daemonizer::Dsl.evaluate(<<-G)
      pool :test do
        set_option :simple, "simple_value"
      end
    G
  end

  it "should initialize block setting correctly" do
    Daemonizer::Option.expects(:new).with(:lambda, kind_of(Proc), any_of(true, nil)).once
    Daemonizer::Dsl.evaluate(<<-G)
      pool :test do
        set_option :lambda do
          "lambda_value"
        end
      end
    G
  end

  it "should correctly set option_handlers" do
    @eval = Daemonizer::Dsl.evaluate(<<-G)
      pool :test do
        set_option :option1, "option1_value"
        set_option :option2, "option1_value"
        set_option :option3, "option1_value"
      end
    G
    @eval.configs[:test][:handler_options].should be_kind_of(Hash)
    @eval.configs[:test][:handler_options].size.should == 3
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
        context "with arity == 0" do
          it do
            Daemonizer::Option.new(:option, lambda { "lambda" }, true).
              value(OptionsSpecHandler.new).
              should == "lambda"
          end
        end

        context "with arity == 2" do
          it do
            Daemonizer::Option.new(:option, lambda { |worker_id, workers_count| "#{worker_id}/#{workers_count}" }, true).
              value(OptionsSpecHandler.new).
              should == "1/1"
          end
        end

        context "with arity == 1" do

          it do
            lambda {
              Daemonizer::Option.new(:option, lambda { |worker_id| "lambda" }, true).
              value(OptionsSpecHandler.new)
            }.should raise_error(Daemonizer::Option::OptionError)
          end

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
