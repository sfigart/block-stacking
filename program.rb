require 'logger'

class Program
  attr_reader :node, :scores, :boards
  
  def initialize(node=nil, boards=[])
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    
    @node = node
    @boards = [*boards]
    @scores = []
  end
  
  def add_board(board)
    @boards << board
  end
  
  def execute
    @scores = []
    @boards.each do |board|
      @node.execute(board)
      add_score(board.score)
    end
  end
  
  # Smaller is better (0 = perfect)
  def raw_fitness
    @scores.inject(0, :+)
  end
  
  # Larger is better (range is between 0 and 1)
  def adjusted_fitness
    1 / (1 + raw_fitness.to_f)
  end
  
  # Larger is better (All normalized fitness will sum to 1)
  def normalized_fitness(total)
    adjusted_fitness / total
  end
  
  def add_score(score)
    @scores << score
  end
  
  def display
    node.to_s
  end
end