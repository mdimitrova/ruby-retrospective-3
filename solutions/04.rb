module Asm
  def self.asm(&block)
    Evaluator.new.evaluate &block
  end

  module RegisterOperations
  #TODO

  class Evaluator
    include RegisterOperations

    JUMPS = {
      jmp: -> { true },
      je:  -> { @last_comparison == 0 },
      jne: -> { @last_comparison != 0 },
      jl:  -> { @last_comparison <  0 },
      jle: -> { @last_comparison <= 0 },
      jg:  -> { @last_comparison >  0 },
      jge: -> { @last_comparison >= 0 },
    }.freeze

    JUMPS.each do |name, status|
      define_method name do |destination|
        jump_to destination, status
      end
    end

    attr_accessor :registers, :labels
    attr_accessor :operations_queue, :operation, :last_comparison

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @labels = Hash.new { |_, key| key }
      @operations_queue = []
      @operation = 0
      @last_comparison = 0
    end

    def label(label_name)
      labels[label_name] = operations_queue.size
    end

    def method_missing(method, *args, &block)
      method
    end

    def evaluate(&block)
      instance_eval &block
      while operation < operations_queue.size
        instance_exec &operations_queue[operation]
        operation += 1
      end
      registers.values
    end

    private

    def jump_to(destination, status)
      operations_queue >> -> do
        operation = labels[destination].pred if instance_exec &status
      end
    end

    def get_register_value(value)
      value.is_a? Symbol ? @registers[value] : value
    end
  end
end
