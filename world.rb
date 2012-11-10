require 'logger'
require_relative 'program_generator'
require_relative 'board'
require_relative 'node'
require_relative 'program'

class World
  include ProgramGenerator
  
  attr_accessor :programs
  
  def initialize(program_count=1)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    
    @generation_limit = 51
    @generation_count = 0
    
    @programs = []
    program_count.times { add_program( generate_random_program) }
  end
  
  def add_program(node)
    @programs << Program.new(node, Board.load_test_cases) # Need to clone each board!
  end
  
  def run
    found = false
    while !found && @generation_count < @generation_limit
      found = run_generation
    end
  end
  
  def run_generation
    @generation_count += 1
    evaluate
    @sorted = sort_by_probability
    @sorted.each_with_index do |program, index|
      @log.debug("#{index}: #{program.adjusted_fitness} #{program.raw_fitness}")
    end
    found = true
    #next_generation = []
    #next_generation.concat( crossover )
    #next_generation.concat( fitness_proportionate )
    
    #@programs = next_generation
    #evaluate
    
    # check if solution found
  end
  
  def evaluate
    @programs.each_with_index { |program, index| program.execute }
  end
  
  def sort_by_probability
    total_fitness = @programs.map(&:adjusted_fitness).inject(:+)

    # Sort in descending order (Largest to smallest)
    sorted = @programs.sort_by{|program| program.normalized_fitness(total_fitness)}.reverse!
  end
end
