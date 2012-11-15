require 'logger'
require_relative 'board'

class TestCaseGenerator
  attr_accessor :goal, :boards
  def initialize(goal='universal')
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG

    @goal = goal
    @boards = []
    @log.debug "goal: #{goal}"
  end
  
  # (1) the l0 cases where the 0-9 blocks in the STACK are already
  # in correct order
  def test_case_1
    @boards << Board.new('', 'universal')
    @boards << Board.new('u', 'niversal')
    @boards << Board.new('un', 'iversal')
    @boards << Board.new('uni', 'versal')
    @boards << Board.new('univ', 'ersal')
    @boards << Board.new('unive', 'rsal')
    @boards << Board.new('univer', 'sal')
    @boards << Board.new('univers', 'al')
    @boards << Board.new('universa', 'l')
    @boards << Board.new('universal', '')
  end
  
  # (2) the 8 cases where there is precisely one out-of-order block
  # in the initial STACK on top of whatever number of correctly-ordered
  # blocks, if any, happen to be in the initial STACK
  def test_case_2
    @boards << Board.new('l', 'universa')   
    @boards << Board.new('ul', 'niversa')   
    @boards << Board.new('unl', 'iversa')
    @boards << Board.new('unil', 'versa')
    @boards << Board.new('univl', 'ersa')
    @boards << Board.new('univel', 'rsa')
    @boards << Board.new('univerl', 'sa')
    @boards << Board.new('universl', 'a')
  end
  # (3) a structured random sampling of 148 additional environmental
  # cases with 0, 1, 2, ...,8 correctly-ordered blocks in the initial
  # STACK and various random numbers 2, 3, 4, ... out-of-order blocks
  # on top of the correctly- ordered blocks
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
  
  def board_keys
    @boards.collect(&:key)
  end
  
  def display
    @boards.each_with_index do |board, index|
      @log.debug("#{index+1}: #{board.key}")
    end
    
    uniq = @boards.uniq{|board|"#{board.stack}:#{board.table}"}
    @log.debug "Total: #{@boards.size}: unique: #{uniq.size}"
  end
  
  def complete_random
    166.times do 
      @boards << create_board(0)
    end
  end
end

t = TestCaseGenerator.new
#t.test_case_1
#t.test_case_2
#t.test_case_3
t.complete_random
t.display