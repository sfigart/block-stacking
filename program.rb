require 'logger'

class Program
  attr_reader :node, :scores, :boards
  
  def initialize(node=nil, boards=[])
    @log = Logger.new(STDOUT)
    @log.level = Logger::FATAL
    
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
    @log.info("program.reproduce")
    # Reproduce with self
    new_node1, new_node2 = @node.crossover(@node)
    node = [new_node1, new_node2].sample
    @log.debug("  node: #{node}")
    Program.new(node, Board.load_test_cases)
  end
  
  def crossover(other_program)
    @log.info("program.crossover")
    @log.debug("  node: #{@node}")
    @log.debug("  other_program.node: #{other_program.node}")
    new_node1, new_node2 = @node.crossover(other_program.node)
    @log.debug("  new_node1: #{new_node1}")
    @log.debug("  new_node2: #{new_node2}")
    return Program.new(new_node1, Board.load_test_cases),
           Program.new(new_node2, Board.load_test_cases)
  end
  
  def execute
    @log.debug "program.execute Program: #{@node} - node is nil?#{@node.nil?}"
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