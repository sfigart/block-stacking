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
    @log.level = Logger::FATAL
    
    @generation_limit = 51
    @generation_count = 0
    
    @programs = []
    program_count.times { add_program( generate_random_program) }
  end
  
  def add_program(node)
    @programs << Program.new(node, Board.load_test_cases) # Need to clone each board!
  end
  
  def run
    @log.info("run generation: #{@generation_count}")
    found = false
    while !found && @generation_count < @generation_limit
      found = run_generation
    end
    
    @log.info "Found: #{found}, generation_count : #{@generation_count}"
  end
  
  def run_generation
    @log.info("run_generation #{@generation_count} programs size: #{@programs.size}")
    @generation_count += 1
    evaluate  
    @programs = next_generation
    
    evaluate
    found = solution_found?
  end
  
  def next_generation
    @log.info("next_generation")
    @sorted = sort_by_probability
    new_programs = []
    new_programs.concat( crossover )
    new_programs.each_with_index do |program, index|
      @log.debug"  #{index}: nil program? #{program.node.nil?} #{program.display}"
    end
    new_programs.concat( fitness_proportionate )
    new_programs
  end
  
  def solution_found?
    scores = @programs.collect(&:raw_fitness)
    scores.min == 0 ? true : false
  end
  
  # Use 90% of the population and create 2 children
  def crossover
    @log.info("world.crossover")
    pairs_to_select = ((@sorted.size * 0.9) / 2).floor # 90%, 1/2 because processing as pairs
    children = []
    paired_programs = @sorted.each_slice(2).to_a
    for i in 0..pairs_to_select - 1
      @log.debug("  pair[#{i}][0]: #{paired_programs[i][0].display}")
      @log.debug("  pair[#{i}][1]: #{paired_programs[i][1].display}")
      program1, program2 = paired_programs[i][0].crossover(paired_programs[i][1])
      @log.debug("  program1: #{program1.display}")
      @log.debug("  program2: #{program2.display}")
      children << program1
      children << program2
    end
    @log.debug "  children size: #{children.size}"
    children
  end
  
  def fitness_proportionate
    @log.info("fitness_proportionate")
    children = []
    num_to_select = (@sorted.size * 0.1).floor + 1 # 10%
    @log.debug("  num_to_select #{num_to_select}")
    for i in 0..num_to_select - 1
      children << @sorted[i].reproduce
    end
    @log.debug "  children size: #{children.size}"
    children
  end
  
  def evaluate
    @log.info("evaluate")
    @programs.each_with_index { |program, index| program.execute }
  end
  
  def sort_by_probability
    @log.info("sort_by_probability")
    total_fitness = @programs.map(&:adjusted_fitness).inject(:+)

    # Sort in descending order (Largest to smallest)
    sorted = @programs.sort_by{|program| program.normalized_fitness(total_fitness)}.reverse!
  end
end
