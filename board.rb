require 'logger'

class Board
  @@boards = []
  attr_accessor :stack, :table
  def initialize(stack_chars, table_chars)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @stack = stack_chars.split('') rescue []
    @table = table_chars.split('') rescue []
  end
  
  def key
    "#{@stack.join}:#{@table.join}"
  end
  
  def to_s
    "Stack: #{@stack.join} Table: #{@table.join}"
  end
  
  def self.load_test_cases(filename='boards.csv')
    boards = []
    File.open(filename).each do |line|
      stack, table = line.chomp.split(',')
      boards << Board.new(stack, table)
    end
    boards
  end
end