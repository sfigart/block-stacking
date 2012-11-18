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
    @programs.each {|program| puts program.display}
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
    
    puts "Found: #{found}, generation_count : #{@generation_count}"
    display_program(@sorted_programs.first)
    
  end
  
  def display_program(program)
    puts "scores: #{program.display_scores}"
    puts "program: #{program.display}"
    program.boards.each_with_index do |board, index|
      puts "#{index}: [#{board.stack.join}] [#{board.table.join}]"
    end
  end
  
  def run_generation
    logger.warn("run_generation #{@generation_count} programs size: #{@programs.size}")
    @generation_count += 1
    evaluate
    @sorted_programs = sort_by_probability
    best = @sorted_programs.first
    puts "#{Time.now.strftime("%R")} %3d best: #{best.display_scores} Correct Boards: #{best.correct_boards_count} " % @generation_count
    #puts "#{Time.now.strftime("%I:%M%p")} %3d best: #{best.display_scores}" % @generation_count
    return solution_found?
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
      program1, program2 = paired_programs[i][0].crossover(paired_programs[i][1])
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
    @programs.sort_by{|program| program.normalized_fitness(total_fitness)}.reverse!
  end
end
