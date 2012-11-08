require "test/unit"

require_relative "world"
require_relative 'node'

class TestProgram < Test::Unit::TestCase
  def setup
    @goal = ["a","b","c"]
    @stack = ["a"]
    @table = ["c","b"]
    @world = World.new(@goal, @stack, @table, 0)
  end
  
  def test_simple_program
    program = Node.new(:mt, Node.new(:cs))
    @world.add_program(program)
    @world.run
    assert_equal([], @world.stack)
    assert_equal('abc', @world.table.sort.join)
  end

  def test_simple_program2
    program = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    program.arg1 = mt_cs
    program.arg2 = not_cs

    @world = World.new(['a', 'b', 'c'], ['b', 'a', 'c'], [], 0)
    @world.add_program(program)
    @world.run

    assert_equal([], @world.stack)
    assert_equal('abc', @world.table.sort.join)
  end

  def test_simple_program3
    program = Node.new(:du)
    ms_nn = Node.new(:ms, Node.new(:nn))
    not_nn = Node.new(:not, Node.new(:nn))
    program.arg1 = ms_nn
    program.arg2 = not_nn
    
    @world = World.new(['a', 'b', 'c'], [], ['b', 'a', 'c'], 0)
    @world.add_program(program)
    @world.run

    assert_equal('abc', @world.stack.join)
    assert_equal([], @world.table)
  end

  def test_simple_program4
    program2 = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    program2.arg1 = mt_cs
    program2.arg2 = not_cs

    program3 = Node.new(:du)
    ms_nn = Node.new(:ms, Node.new(:nn))
    not_nn = Node.new(:not, Node.new(:nn))
    program3.arg1 = ms_nn
    program3.arg2 = not_nn

    program = Node.new(:eq)
    program.arg1 = program2
    program.arg2 = program3    

    @world = World.new(['a', 'b', 'c'], ['c'], ['b', 'a'], 0)
    @world.add_program(program)
    @world.run

    assert_equal('abc', @world.stack.join)
    assert_equal([], @world.table)
  end
end