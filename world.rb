require 'logger'
require_relative 'terminal_arguments'
require_relative 'primitive_functions'
require_relative 'program_generator'
require_relative 'node'

class World
  include TerminalArguments
  include PrimitiveFunctions
  include ProgramGenerator
  
  attr_reader :goal, :stack, :table, :terminal_arguments, :programs
  
  def initialize(goal, stack, table, program_count=1)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    
    @goal = goal
    @stack = stack
    @table = table
    
    create_terminal_arguments
    
    @programs = []
    program_count.times { add_program(generate_random_program) }
  end
  
  def add_program(program)
    @programs << program
  end
  
  def run
    @programs.each {|program| program.execute(self)}
  end
  
  def display
    puts ''
    puts "Goal :" + @goal.inspect
    puts "Stack:" + @stack.inspect
    puts "Table:" + @table.inspect
  end
end
