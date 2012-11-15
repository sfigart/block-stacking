require_relative 'logging'
require_relative 'board'
require_relative 'writer'

class TestCaseGenerator
  include Logging
  
  attr_accessor :goal, :boards
  def initialize(goal='universal')
    @goal = goal
    @boards = []
    logger.debug "goal: #{goal}"
  end
  
  # (1) the l0 cases where the 0-9 blocks in the STACK are already
  # in correct order
  def test_case_1
    @boards << Board.new(@goal, '', 'universal')
    @boards << Board.new(@goal, 'u', 'niversal')
    @boards << Board.new(@goal, 'un', 'iversal')
    @boards << Board.new(@goal, 'uni', 'versal')
    @boards << Board.new(@goal, 'univ', 'ersal')
    @boards << Board.new(@goal, 'unive', 'rsal')
    @boards << Board.new(@goal, 'univer', 'sal')
    @boards << Board.new(@goal, 'univers', 'al')
    @boards << Board.new(@goal, 'universa', 'l')
    @boards << Board.new(@goal, 'universal', '')
  end
  
  # (2) the 8 cases where there is precisely one out-of-order block
  # in the initial STACK on top of whatever number of correctly-ordered
  # blocks, if any, happen to be in the initial STACK
  def test_case_2
    @boards << Board.new(@goal, 'l', 'universa')   
    @boards << Board.new(@goal, 'ul', 'niversa')   
    @boards << Board.new(@goal, 'unl', 'iversa')
    @boards << Board.new(@goal, 'unil', 'versa')
    @boards << Board.new(@goal, 'univl', 'ersa')
    @boards << Board.new(@goal, 'univel', 'rsa')
    @boards << Board.new(@goal, 'univerl', 'sa')
    @boards << Board.new(@goal, 'universl', 'a')
  end
  # (3) a structured random sampling of 148 additional environmental
  # cases with 0, 1, 2, ...,8 correctly-ordered blocks in the initial
  # STACK and various random numbers 2, 3, 4, ... out-of-order blocks
  # on top of the correctly- ordered blocks
  def test_case_3a
    while @boards.size < 148
      board = create_test_case(rand(9))
      @boards << board unless board.nil?
      puts "test_case_3a"
    end        
  end
  
  def create_test_case(length)
    keys = board_keys
    need_board = true
    limit = 0
    
    while need_board
      puts "need board loop"
      goal = 'universal'
      stack     = goal[0,length]
      remainder = goal[-9 + length,9]
      pivot     = rand(remainder.size)
      stack.concat(remainder[0, pivot].split('').shuffle.join)
      table     = remainder[(remainder.size * -1) + pivot, remainder.size].split('').shuffle.join
      puts "generated: #{stack}:#{table}"
      
      if !keys.include?("#{stack}:#{table}")
        need_board = false
        board = Board.new(@goal, stack, table)
        puts "valid board #{board.key}"
        return board
      else
        limit += 1
        need_board = false if limit > 5
        nil
      end
    end
  end
=begin
  def test_case_3
    #univers [al]
    @boards << Board.new('univers', 'la')
    
    #univer [sal]
    @boards << Board.new('univer', 'sla')
    @boards << Board.new('univer', 'als')
    @boards << Board.new('univer', 'asl')
    @boards << Board.new('univer', 'las')
    @boards << Board.new('univer', 'lsa')

    #unive [rsal] ... un [iversal]
    23.times do
      @boards << create_board(5)
    end
    29.times do
      @boards << create_board(4)
      @boards << create_board(3)
      @boards << create_board(2)
    end

    #u [niversal]
    32.times do
      @boards << create_board(1)
    end
  end

  def create_board(length)
    keys = board_keys

    need_board = true
    while need_board
      board = Board.new(@goal, @goal[0,length], @goal[-9 + length, 9].split('').shuffle.join)
      if !keys.include?(board.key)
        need_board = false
        return board
      end
    end
  end
=end  
  def board_keys
    @boards.collect(&:key)
  end
  
  def display
    writer = Writer.new("boards2.csv")
    @boards.each_with_index do |board, index|
      logger.debug("#{index+1}: #{board.key}")
      writer.puts("#{board.stack.join},#{board.table.join}")
    end
    
    uniq = @boards.uniq{|board|"#{board.stack}:#{board.table}"}
    logger.debug "Total: #{@boards.size}: unique: #{uniq.size}"
  end
  
  def complete_random
    166.times do 
      @boards << create_board(0)
    end
  end
end

t = TestCaseGenerator.new
t.test_case_1
t.test_case_2
t.test_case_3a
#t.complete_random
t.display