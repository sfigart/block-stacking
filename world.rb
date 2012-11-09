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
    
    @programs = []
    program_count.times { add_program( generate_random_program) }
  end
  
  def add_program(node)
    @programs << Program.new(node, Board.load_test_cases) # Need to clone each board!
  end
  
  def run
    @programs.each_with_index do |program, index|
      @log.debug program.display
      program.execute
      @log.debug "#{index} Raw Fitness:\t#{program.raw_fitness}\tAdjusted Fitness: #{program.adjusted_fitness}"
    end
  end
end
