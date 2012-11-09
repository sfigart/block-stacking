require 'logger'

class Program
  attr_reader :node, :scores, :boards
  
  def initialize(node=nil, boards=[])
    @node = node
    @boards = [*boards]
    @scores = []
  end
  
  def add_board(board)
    @boards << board
  end
  
  def execute
    @boards.each do |board|
      @node.execute(board)
      @scores << board.score
    end
  end
end