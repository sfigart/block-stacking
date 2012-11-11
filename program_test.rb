require "test/unit"

require_relative 'board'
require_relative 'node'
require_relative 'program'

class TestProgram < Test::Unit::TestCase
  def setup
    @goal = 'abc'
    @stack = 'a'
    @table = 'cb'
    @board = Board.new(@goal, @stack, @table)
  end

  def setup_fitness
    @program = Program.new
    @program.add_score(25)
    @program.add_score(25)
  end
  
  def test_program
    not_ms_cs = Node.new(:not, Node.new(:ms, Node.new(:cs)))
    @program = Program.new(not_ms_cs, @board)
    @program.execute
  end

  def test_raw_fitness
    setup_fitness
    score = @program.scores.inject(0, :+)
    assert_equal(50, score)
    assert_equal(score, @program.raw_fitness)
  end
  
  def test_adjusted_fitness
    setup_fitness
    assert_in_delta(0.019607843, @program.adjusted_fitness, 0.000000001)
  end
  
  def test_normalized_fitness
    setup_fitness
    assert_in_delta(1, @program.normalized_fitness(@program.adjusted_fitness))
    assert_in_delta(0.5, @program.normalized_fitness(@program.adjusted_fitness + @program.adjusted_fitness))
    assert_in_delta(0.333, @program.normalized_fitness(@program.adjusted_fitness * 3))
  end

  def test_simple_program
    node = Node.new(:mt, Node.new(:cs))
    program = Program.new(node, @board)
    program.execute

    assert_equal([], @board.stack)
    assert_equal('abc', @board.table.sort.join)
    assert_equal(25 + 25 + 25, program.scores.first)
  end

  def test_simple_program2
    node = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    node.arg1 = mt_cs
    node.arg2 = not_cs

    @board = Board.new('abc', 'bac', '')
    program = Program.new(node, @board)
    program.execute
    
    assert_equal([], @board.stack)
    assert_equal('abc', @board.table.sort.join)
    assert_equal(25 + 25 + 25, program.scores.first)
  end

  def test_simple_program3
    node = Node.new(:du)
    ms_nn = Node.new(:ms, Node.new(:nn))
    not_nn = Node.new(:not, Node.new(:nn))
    node.arg1 = ms_nn
    node.arg2 = not_nn
    
    board = Board.new('abc', '', 'bac')
    program = Program.new(node, board)
    program.execute

    assert_equal('abc', board.stack.join)
    assert_equal([], board.table)
    assert_equal(0, program.scores.first)
  end

  def test_simple_program4
    node2 = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    node2.arg1 = mt_cs
    node2.arg2 = not_cs

    node3 = Node.new(:du)
    ms_nn = Node.new(:ms, Node.new(:nn))
    not_nn = Node.new(:not, Node.new(:nn))
    node3.arg1 = ms_nn
    node3.arg2 = not_nn

    node = Node.new(:eq)
    node.arg1 = node2
    node.arg2 = node3

    board = Board.new('abc', 'c', 'ab')
    program = Program.new(node, board)
    program.execute

    assert_equal('abc', board.stack.join)
    assert_equal([], board.table)
    assert_equal(0, program.scores.first)
  end
end