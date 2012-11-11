require "test/unit"

require_relative "board"

class TestBoard < Test::Unit::TestCase

  def setup
    @goal = "abc"
    @stack = "a"
    @table = "cb"
    @board = Board.new(@goal, @stack, @table)
  end
  
  def test_key
    assert_equal("a:cb",@board.key)
  end
  
  def test_score
    # stack = a table = cb
    assert_equal(25 + 25, @board.score)
    
    # stack = '' table = abc
    @board.mt(@board.cs)
    assert_equal(25 + 25 + 25, @board.score)
    
    # add a, then b, then c
    @board.ms(@board.nn)
    assert_equal(25 + 25, @board.score)
    @board.ms(@board.nn)
    assert_equal(25, @board.score)
    @board.ms(@board.nn)
    assert_equal(0, @board.score)
  end
  
  def test_score_nothing_right
    board = Board.new('universal', '', 'universal')
    assert_equal(225, 'universal'.size * Board::DISTANCE_PENALTY)
    assert_equal('universal'.size * Board::DISTANCE_PENALTY, board.score)
  end
  
  def test_score_somthing_in_stack
    board = Board.new('universal', 'inu', 'versal')
    # i - u = 12
    # n - n = 0
    # u - i = 12
    # versal.size * 25 = 150
    # total = 12 + 0 + 12 + 150 = 174
    assert_equal(12 + 0 + 12 + 150, board.score)
  end
  
  def test_sort
    board2 = Board.new('def','f','de')
    boards = [board2, @board].sort
    assert_equal(@board, boards.first)
    assert_equal(board2, boards.last)
  end
  
  def test_initialize
    assert_equal(@goal.split(''), @board.goal)
    assert_equal(@stack.split(''), @board.stack)
    assert_equal(@table.split(''), @board.table)
  end

  def test_cs
    assert_equal('a', @board.cs)

    # Shouldn't be able to assign directly to stack outside of
    # functions, but okay for testing
    @board.stack << 'b'
    assert_equal(2, @board.stack.size)
    assert_equal('b', @board.cs)

    @board.stack.clear
    assert_nil(@board.cs)
  end
  
  def test_nn
    assert_equal('b', @board.nn)

    @board.stack.push('b')
    assert_equal('c', @board.nn)

    @board.stack.clear
    assert_equal('a', @board.nn)

    @board.stack.push('a', 'b', 'c')
    assert_nil(@board.nn)
  end
  
  def test_tb
    assert_equal('a', @board.tb)
    @board.stack.push('b')
    
    assert_equal('b', @board.tb)
    
    @board.stack.clear
    @board.stack.push('a', 'c')
    assert_equal('a', @board.tb)
    
    @board.stack.clear
    @board.stack.push('c')
    assert_nil(@board.tb)
    
    @board.stack.clear
    assert_nil(@board.tb)
  end
  
  def test_ms
    assert_equal(false, @board.ms('z'))
    
    assert_equal(true, @board.ms('b'))
    assert_equal(1, @board.table.size)
    assert_equal('c', @board.table.last)

    assert_equal(2, @board.stack.size)
    assert_equal('b', @board.tb)
    assert_equal('b', @board.cs)
    assert_equal('c', @board.nn)
    
    @board.ms('c')
    assert_equal(0, @board.table.size)
    assert_equal(3, @board.stack.size)
    assert_equal('c', @board.tb)
    assert_equal('c', @board.cs)
    assert_nil(@board.nn)
  end
  
  def test_mt
    assert_equal(false, @board.mt('z') )

    @board.mt('a')
    assert_equal(0, @board.stack.size)
    assert_equal(3, @board.table.size)
    
    @board.ms('a')
    @board.ms('b')
    @board.ms('c')
    assert_empty(@board.table)
    assert_equal(3, @board.stack.size)
    assert_equal('abc', @board.stack.join)
    
    assert(@board.mt('a'),'is not true')
    assert(@board.table.include? 'c')
    assert(@board.mt('a'),'is not true')
    assert(@board.table.include? 'b')
    assert(@board.mt('a'),'is not true')
    assert(@board.table.include? 'a')
    assert_empty(@board.stack)
    assert_nil(@board.cs)
    assert_nil(@board.tb)
    assert_equal('a', @board.nn)
  end
  
  def test_eq
    x = 'a'
    y = 'b'
    assert_equal(false, @board.eq(x, y))
    
    x = []
    y = []
    assert_equal(true, @board.eq(x, y))
    
    x = 'a'
    y = 'b'
    assert_equal(false, @board.eq(x, y))
    assert_equal(false, @board.eq(x.to_s, y.to_s))

    x = 'c'
    y = 'c'
    assert_equal(true, @board.eq(x.to_s, y.to_s))
  end
  
  def test_not
    x = false
    result = @board.not(x)
    assert(result, 'did not return true')
    
    x = []
    result = @board.not(x)
    assert(result, 'did not return true')    

    x = nil
    result = @board.not(x)
    assert(result, 'did not return true')
    
    x = 'a'
    result = @board.not(x)
    assert_equal(false, result)

    x = ['a']
    result = @board.not(x)
    assert_equal(false, result)
    
    x = true
    result = @board.not(x)
    assert_equal(false, result)
  end
  
  def display
    puts ''
    puts "Stack " + @board.stack.inspect
    puts "Table " + @board.table.inspect
  end
  
end