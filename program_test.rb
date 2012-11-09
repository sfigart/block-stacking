require "test/unit"

require_relative "board"
require_relative 'node'

class TestProgram < Test::Unit::TestCase
  def setup
    @goal = 'abc'
    @stack = 'a'
    @table = 'cb'
    @board = Board.new(@goal, @stack, @table)
  end

  def test_simple_program
    program = Node.new(:mt, Node.new(:cs))
    program.execute(@board)
    assert_equal([], @board.stack)
    assert_equal('abc', @board.table.sort.join)
  end

  def test_simple_program2
    program = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    program.arg1 = mt_cs
    program.arg2 = not_cs

    @board = Board.new('abc', 'bac', '')
    program.execute(@board)
    
    assert_equal([], @board.stack)
    assert_equal('abc', @board.table.sort.join)
  end

  def test_simple_program3
    program = Node.new(:du)
    ms_nn = Node.new(:ms, Node.new(:nn))
    not_nn = Node.new(:not, Node.new(:nn))
    program.arg1 = ms_nn
    program.arg2 = not_nn
    
    @board = Board.new('abc', '', 'bac')
    program.execute(@board)

    assert_equal('abc', @board.stack.join)
    assert_equal([], @board.table)
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

    @board = Board.new('abc', 'c', 'ab')
    program.execute(@board)

    assert_equal('abc', @board.stack.join)
    assert_equal([], @board.table)
  end
end