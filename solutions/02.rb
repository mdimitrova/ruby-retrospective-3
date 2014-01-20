class Task
  include Enumerable

  def initialize(args)
    @status = args[0].downcase.to_sym
    @description = args[1]
    @priority = args[2].downcase.to_sym
    @tags = args[3].nil? ? [] : args[3].split(', ')
  end

  def status
    @status
  end

  def description
    @description
  end

  def priority
    @priority
  end

  def tags
    return [] if @tags.nil?
    @tags
  end

  def include?(criteria)
    criteria.get_criteria.all? { |criterion| check_criterion(criterion) }
  end

  def check_criterion(criterion)
    if criterion.class == Symbol
      status == criterion or priority == criterion
    elsif criterion.class == String
      tags.include? criterion
    end
  end

  def check_tags(tags_list)
    tags_list.all? { |searched_tag| tags.include? searched_tag }
  end
end

class TodoList
  include Enumerable

  def initialize(text)
    @list = text
  end

  def each
    array = @list.to_a
    array.each { |task| yield task }
  end

  def self.parse(text)
    parsed = text.lines().map { |line| line.chomp().split('|').map(&:strip) }
    todo_list = TodoList.new(parsed.map { |task| Task.new(task) })
  end

  def filter(criterion)
    filtered_list = TodoList.new( select { |task| task.include? criterion })
  end

  def adjoin(other)
    self_array = self.each { |task| task }
    other_array = other.each { |task| task }
    adjoined_list = TodoList.new([self_array, other_array].flatten)
  end

  def tasks_todo
    @list.select { |task| task.status == :todo }.size
  end

  def tasks_in_progress
    @list.select { |task| task.status == :current }.size
  end

  def tasks_completed
    @list.select { |task| task.status == :done }.size
  end

  def completed?
    @list.all? { |task| task.status == :done }
  end
end

class Criteria
  def initialize(criteria)
    @criteria = criteria
  end

  def self.status(criterion)
    status_criterion = Criteria.new([criterion])
  end

  def self.priority(criterion)
    status_criterion = Criteria.new([criterion])
  end

  def self.tags(criteria_tags)
    if criteria_tags.empty?
      tags_criterion = Criteria.new([])
    else
      tags_criterion = Criteria.new(criteria_tags)
    end
  end

  def get_criteria
    @criteria
  end

  def &(other)
    criteria = Criteria.new([self.get_criteria, other.get_criteria].flatten)
  end

  def |(other)
    criteria = Criteria.new([self.get_criteria, other.get_criteria]) #FIXME
  end

  def !(other)
    #FIXME
  end
end
