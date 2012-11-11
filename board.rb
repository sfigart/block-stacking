require 'logger'
require_relative 'terminal_arguments'
require_relative 'primitive_functions'

class Board
  include TerminalArguments
  include PrimitiveFunctions
  
  attr_reader   :goal
  attr_accessor :stack, :table
  
  DISTANCE_PENALTY = 25

  def initialize(goal_chars,stack_chars, table_chars)
    @log = Logger.new(STDOUT)
    @log.level = Logger::FATAL
    
    @goal  = goal_chars.nil?  ? [] : goal_chars.split('')
    @stack = stack_chars.nil? ? [] : stack_chars.split('')
    @table = table_chars.nil? ? [] : table_chars.split('')
  end
  
  def key
    "#{@stack.join}:#{@table.join}"
  end
  
  def score
    total = 0
    
    return @goal.size * DISTANCE_PENALTY if @stack.empty?
    
    # For character in stack
    for i in 0..@stack.size - 1
      total += (@stack[i].ord - @goal[i].ord).abs
    end
    
    # For each character leftover in table * 26 (length of alphabet)
    total += @table.size * DISTANCE_PENALTY
    
    total
  end
  
  def to_s
    "Goal: #{@goal.join} Stack: #{@stack.join} Table: #{@table.join}"
  end

  def <=>(other)
    self.key <=> other.key
  end
  
  def self.load_test_cases(goal='universal', filename='boards.csv')
    boards = []
    File.open(filename).each do |line|
      stack, table = line.chomp.split(',')
      boards << Board.new(goal, stack, table)
    end
    boards
  end
end