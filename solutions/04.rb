module Asm
  def self.asm(&block)
    Evaluator.new.evaluate &block
  end

  module RegisterOperations
    def mov(destination_register, source)
      @operations_queue << -> do
        @registers[destination_register] = get_register_value(source)
      end
    end

    def inc(destination_register, value = 1)
      @operations_queue << -> do
        @registers[destination_register] += get_register_value(value)
      end
    end

    def dec(destination_register, value = 1)
      @operations_queue << -> do
        @registers[destination_register] -= get_register_value(value)
      end
    end

    def cmp(register, value)
      @operations_queue << -> do
        @last_comparison = (@registers[register] <=> get_register_value(value))
      end
    end

    def get_register_value(value)
      @registers[value] or value
    end
  end

  class Evaluator
    include RegisterOperations

    JUMP_OPERATIONS = {
      jmp: -> { true },
      je:  -> { @last_comparison == 0 },
      jne: -> { @last_comparison != 0 },
      jl:  -> { @last_comparison <  0 },
      jle: -> { @last_comparison <= 0 },
      jg:  -> { @last_comparison >  0 },
      jge: -> { @last_comparison >= 0 },
    }.freeze

    JUMP_OPERATIONS.each do |name, status|
      define_method name do |destination|
        jump_to destination, status
      end
    end

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @labels = Hash.new { |_, key| key }
      @operations_queue = []
      @operation = 0
      @last_comparison = 0
    end

    def label(label_name)
      @labels[label_name] = @operations_queue.size
    end

    def method_missing(method, *args, &block)
      method
    end

    def evaluate(&block)
      instance_eval &block
      until @operation == @operations_queue.size
        instance_exec &@operations_queue[@operation]
        @operation += 1
      end
      @registers.values
    end

    private

    def jump_to(destination, status)
      @operations_queue << -> do
        @operation = @labels[destination].pred if instance_exec &status
      end
    end
  end
end
