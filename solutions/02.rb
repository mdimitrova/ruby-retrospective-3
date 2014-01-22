class Task
  include Enumerable

  attr_reader :status, :description, :priority, :tags

  def initialize(args)
    @status = args[0].downcase.to_sym
    @description = args[1]
    @priority = args[2].downcase.to_sym
    @tags = args[3].nil? ? [] : args[3].split(', ')
  end
end

class TodoList
  include Enumerable

  attr_reader :tasks_list

  def initialize(tasks)
    @tasks_list = tasks
  end

  def each
    @tasks_list.each { |task| yield task }
  end

  def self.parse(text)
    parsed = text.lines().map { |line| line.chomp().split('|').map(&:strip) }
    TodoList.new parsed.map { |task| Task.new(task) }
  end

  def filter(criteria)
    TodoList.new select { |task| criteria.matches? task }
  end

  def adjoin(other)
    TodoList.new @tasks_list.concat(other.tasks_list).uniq
  end

  def tasks_todo
    @tasks_list.select { |task| task.status == :todo }.size
  end

  def tasks_in_progress
    @tasks_list.select { |task| task.status == :current }.size
  end

  def tasks_completed
    @tasks_list.select { |task| task.status == :done }.size
  end

  def completed?
    @tasks_list.all? { |task| task.status == :done }
  end
end

class Criteria
  class << self
    def status(status)
      Criteria.new { |task| task.status == status }
    end

    def priority(priority)
      Criteria.new { |task| task.priority == priority }
    end

    def tags(tags)
      Criteria.new { |task| tags & task.tags == tags }
    end
  end

  def initialize(&criteria)
    @criteria = criteria
  end

  def matches?(task)
    @criteria.call task
  end

  def &(other)
    Criteria.new { |task| matches? task and other.matches? task }
  end

  def |(other)
    Criteria.new { |task| matches? task or other.matches? task }
  end

  def !
    Criteria.new { |task| not matches? task }
  end
end
