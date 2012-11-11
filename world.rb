require_relative 'logging'
require_relative 'program_generator'
require_relative 'board'
require_relative 'node'
require_relative 'program'

class World
  include Logging
  include ProgramGenerator
  
  attr_accessor :programs
  
  def initialize(program_count=1)    
    @generation_limit = 51
    @generation_count = 0
    
    @programs = []
    program_count.times { add_program( generate_random_program) }
  end
  
  def add_program(node)
    @programs << Program.new(node, Board.load_test_cases) # Need to clone each board!
  end
  
  def run
    logger.info("run generation: #{@generation_count}")
    found = false
    while !found && @generation_count < @generation_limit
      found = run_generation
      @programs = next_generation unless found
    end
    
    logger.fatal "Found: #{found}, generation_count : #{@generation_count}"
    
  end
  
  def run_generation
    logger.warn("run_generation #{@generation_count} programs size: #{@programs.size}")
    @generation_count += 1
    evaluate
    @sorted_programs = sort_by_probability
    best = @sorted_programs.first
    logger.warn("  best program: #{best.display_scores}")

    return true if solution_found?
    false # Didn't find a solution
  end
  
  def next_generation
    logger.info("next_generation")
    new_programs = []
    new_programs.concat( crossover( @sorted_programs ) )
    new_programs.concat( fitness_proportionate( @sorted_programs ) )
    new_programs
  end
  
  # Use 90% of the population and create 2 children
  def crossover(sorted_programs)
    logger.info("world.crossover")
    pairs_to_select = ((sorted_programs.size * 0.9) / 2).floor # 90%, 1/2 because processing as pairs
    children = []
    paired_programs = sorted_programs.each_slice(2).to_a
    for i in 0..pairs_to_select - 1
      logger.debug("  pair[#{i}][0]: #{paired_programs[i][0].display}")
      logger.debug("  pair[#{i}][1]: #{paired_programs[i][1].display}")
      program1, program2 = paired_programs[i][0].crossover(paired_programs[i][1])
      logger.debug("  program1: #{program1.display}")
      logger.debug("  program2: #{program2.display}")
      children << program1
      children << program2
    end
    logger.debug "  children size: #{children.size}"
    children
  end
  
  def evaluate
    logger.info("world.evaluate generation: #{@generation_count}")
    @programs.each_with_index do |program, index|
      logger.debug("  calling program #{program.display}")
      program.execute
    end
  end 
  
  def fitness_proportionate(sorted_programs)
    logger.info("fitness_proportionate")
    children = []
    num_to_select = (sorted_programs.size * 0.1).to_i
    num_to_select = 1 if num_to_select == 0
    
    logger.debug("  num_to_select #{num_to_select}")
    for i in 0..num_to_select - 1
      children << sorted_programs[i].reproduce
    end
    logger.debug "  children size: #{children.size}"
    children
  end
  
  def solution_found?
    scores = @programs.collect(&:raw_fitness)
    scores.min == 0 ? true : false
  end
  
  def sort_by_probability
    logger.info("sort_by_probability")
    total_fitness = @programs.map(&:adjusted_fitness).inject(:+)

    # Sort in descending order (Largest to smallest)
    sorted = @programs.sort_by{|program| program.normalized_fitness(total_fitness)}.reverse!
  end
end
