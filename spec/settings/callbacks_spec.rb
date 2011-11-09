require "spec_helper"

class CallbacksSpecHandler < SpecHandler
  class <<self
    attr_accessor :call_on_prepare
    attr_accessor :call_on_start
  end

  def start
    self.class.call_on_start && self.class.call_on_start.call
    super
  end

  def prepare(starter, &block)
    self.class.call_on_prepare && self.class.call_on_prepare.call
    super
  end
end


describe "callbacks in Daemonfile" do
  before :each do
    stubs_logger
  end

  %w(after_prepare before_prepare before_start).each do |callback|
    context "initializing #{callback} callbacks" do
      before :each do
        @eval = Daemonizer::Dsl.evaluate(<<-G)
          #{callback} do
            1
          end

          pool :test do
            #{callback} do
              2
            end

            #{callback} do
              3
            end
          end
        G
      end

      it { @eval.configs[:test][:callbacks].should be_kind_of(Hash) }
      it { @eval.configs[:test][:callbacks][callback.to_sym].should be_kind_of(Array) }
      it { @eval.configs[:test][:callbacks][callback.to_sym].size.should == 3 }
      it "should keep valid callbacks order" do
        @eval.configs[:test][:callbacks][callback.to_sym][0].call.should == 1
        @eval.configs[:test][:callbacks][callback.to_sym][1].call.should == 2
        @eval.configs[:test][:callbacks][callback.to_sym][2].call.should == 3
      end
    end
  end
end

describe "callbacks in Daemonizer::Config" do
  before :each do
    stubs_logger
  end

  before :each do
    CallbacksSpecHandler.call_on_prepare = lambda { @engine_state.become('prepare_invoked') }
    CallbacksSpecHandler.call_on_start = lambda { @engine_state.become('start_invoked') }

    @engine_state = states('engine_state').starts_as('pending')
  end

  it "should work in correct order with many callbacks" do
    @before_prepare = mock('before_prepare')
    @before_prepare.expects('touch').when(@engine_state.is('pending')).twice

    @after_prepare = mock('after_prepare')
    @after_prepare.expects('touch').when(@engine_state.is('prepare_invoked')).twice

    @before_start = mock('before_start')
    @before_start.expects('touch').when(@engine_state.is('after_prepare_invoked')).twice

    @callbacks = {
      :before_prepare => [ Proc.new { @before_prepare.touch }, Proc.new { @before_prepare.touch; @engine_state.become('before_prepare_invoked') } ],
      :after_prepare =>  [ Proc.new { @after_prepare.touch }, Proc.new { @after_prepare.touch; @engine_state.become('after_prepare_invoked') }  ],
      :before_start =>   [ Proc.new { @before_start.touch }, Proc.new { @before_start.touch; @engine_state.become('before_start_invoked') } ]
    }

    @engine = Daemonizer::Engine.new(Daemonizer::Config.new(:pool, {
              :workers => 1,
              :pid_file =>"#{tmp_dir}/test1.pid",
              :log_file =>"#{tmp_dir}/test1.log",
              :callbacks => @callbacks,
              :handler => CallbacksSpecHandler
    }))
    @engine.run_prepare_with_callbacks do
      @engine.run_start_with_callbacks
    end
  end

  after :each do
    CallbacksSpecHandler.call_on_prepare = nil
    CallbacksSpecHandler.call_on_start = nil
  end

end
