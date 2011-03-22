module Daemonizer
  class Option
    class OptionError < StandardError; end

    def initialize(option, value, auto_eval = false)
      @option = option
      @value = value
      @auto_eval = auto_eval
      if @auto_eval && !@value.is_a?(Proc)
        raise OptionError, "auto_apply can be used only with callable option"
      end
    end

    def value(handler = nil)
      if @auto_eval && @value.is_a?(Proc)
        if handler && handler.worker_id && handler.workers_count
          if @value.arity == 0 || @value.arity == -1
            return @value.call
          elsif @value.arity == 2
            return @value.call(handler.worker_id, handler.workers_count)
          else
            raise OptionError, "option lambda should accept 0 or 2 parameters"
          end
        else
          raise OptionError, "value called before handler initialized"
        end
      else
        @value
      end
    end

  end
end
