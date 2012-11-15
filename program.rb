require_relative 'logging'

class Program
  include Logging
    
  attr_reader :node, :scores, :boards
  
  def initialize(node=nil, boards=[])  
    @node = node
    @boards = [*boards]
    @scores = []
  end
  
  def add_board(board)
    @boards << board
  end
  
  # This method performs asexual reproduction
  # with a cross over with itself
  def reproduce
    # Reproduce with self
    new_node1, new_node2 = @node.crossover(@node)
    node = [new_node1, new_node2].sample
    Program.new(node, Board.load_test_cases)
  end
  
  def crossover(other_program)
    new_node1, new_node2 = @node.crossover(other_program.node)
    return Program.new(new_node1, Board.load_test_cases),
           Program.new(new_node2, Board.load_test_cases)
  end
  
  def execute
    logger.info("program.execute #{self.display}")
    @scores = []
    @boards.each_with_index do |board, index|
      logger.debug("  #{index} before #{board}")
      @node.execute(board)
      logger.debug("  #{index} after  #{board} : score #{board.score}")
      add_score(board.score)
    end
  end
  
  # Smaller is better (0 = perfect)
  def raw_fitness
    sum_scores = @scores.inject(0, :+)
    return 0 if sum_scores == 0
    
    program_size_penalty = @node.depth_count * 100
    return sum_scores + program_size_penalty
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
  
  def display_scores
    "raw: #{raw_fitness}, adjusted: %.5f, depth: #{@node.depth_count}, count: #{@node.count}" % adjusted_fitness
  end
end