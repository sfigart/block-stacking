require "test/unit"
require_relative 'program_generator'
require_relative 'node'

class ProgramContainer
  include ProgramGenerator
  def initialize
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
  end
end

class TestProgramGenerator < Test::Unit::TestCase
  def setup
    @generator = ProgramContainer.new
  end
  
  def test_generate_random_program
    sizes = {}
    1000.times do
      program = @generator.generate_random_program
      sizes[program] = program.depth_count 
      assert_operator 4, :>=, program.depth_count
    end
  end
  
  def test_build_one_arg_function
    function = @generator.build_one_arg_function(:ms)
    assert_equal(true, [:cs, :tb, :nn].include?(function.arg1.operation))
  end
end