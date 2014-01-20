module Asm
  class Evaluator
    attr_accessor :registers, :operations_queue
    attr_reader :ax, :bx, :cx, :dx

    operations = {
      mov: :'mov',
      inc: :'+',
      dec: :'-',
      cmp: :'<=>',
      jmp: :'jmp',
    }

    operations.each do |operation, operator|
      define_method operation do |register, value = 1|
        @operations_queue << {index: register, value: value, operator: operator}
      end
    end

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @labels = {}
      @operations_queue = []
      @ax = :ax
      @bx = :bx
      @cx = :cx
      @dx = :dx
    end

    def label(label_name)
     @labels[label_name] = operations_queue.size
    end

    def jump(jump_operator, label)
      #TODO
    end

    def method_missing(method)
      method.to_s
    end

    def evaluate(start_index)
      operations_queue.each do |operation|
        index = operation[:index]
        value = operation[:value]
        operator = operation[:operator]
        if [:jmp, :je, :jne, :jl, :jle, :jg, :jge].include? operator
          jump(operator, index)
          break
        else
          update_register(index, value, operator)
        end
      end
      @registers.values
    end

    private

    def update_register(index, value, operator)
      value = registers[value] if value.is_a? Symbol
      if operator == :mov
        registers[index] = value
      elsif operator == :<=>
        operator.to_proc.call(registers[index], value)
      else
        registers[index] = operator.to_proc.call(registers[index], value)
      end
    end
  end

  def self.asm(&block)
    e = Evaluator.new
    e.instance_eval &block
    e.evaluate(0)
  end
end
