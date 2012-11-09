require 'logger'
require_relative 'program_generator'
require_relative 'board'
require_relative 'node'

class World
  include ProgramGenerator
  
  attr_accessor :boards, :programs
  
  def initialize(program_count=1)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    
    @programs = []
    create_terminal_arguments
    program_count.times { add_program(generate_random_program) }
    
    @boards = Board.load_test_cases
  end
  
  def add_program(program)
    @programs << program
  end
  
  def run
    @programs.each {|program| program.execute(self)}
  end
end
