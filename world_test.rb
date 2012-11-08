require "test/unit"

require_relative "world"

class Du_test
  attr_reader :result
  def call_me
    @result = rand(2) == 1
  end
  
  def call_me_true
    @result = true
  end
  
  def check_me
    @result
  end
  
  def execute(arg)
    return true
  end
end

class TestWorld < Test::Unit::TestCase

  def setup
    @goal = ["a","b","c"]
    @stack = ["a"]
    @table = ["c","b"]
    @world = World.new(@goal, @stack, @table)
  end
  
  def test_initialize
    assert_equal(@goal, @world.goal)
    assert_equal(@stack, @world.stack)
    assert_equal(@table, @world.table)
  end

  def test_cs
    assert_equal('a', @world.cs)

    # Shouldn't be able to assign directly to stack outside of
    # functions, but okay for testing
    @stack << 'b'
    assert_equal(2, @world.stack.size)
    assert_equal('b', @world.cs)

    @stack.clear
    assert_nil(@world.cs)
  end
  
  def test_nn
    assert_equal('b', @world.nn)

    @stack.push('b')
    assert_equal('c', @world.nn)

    @stack.clear
    assert_equal('a', @world.nn)

    @stack.push('a', 'b', 'c')
    assert_nil(@world.nn)
  end
  
  def test_tb
    assert_equal('a', @world.tb)
    @stack.push('b')
    
    assert_equal('b', @world.tb)
    
    @stack.clear
    @stack.push('a', 'c')
    assert_equal('a', @world.tb)
    
    @stack.clear
    @stack.push('c')
    assert_nil(@world.tb)
    
    @stack.clear
    assert_nil(@world.tb)
  end
  
  def test_ms
    assert_equal(false, @world.ms('z'))
    
    assert_equal(true, @world.ms('b'))
    assert_equal(1, @world.table.size)
    assert_equal('c', @world.table.last)

    assert_equal(2, @world.stack.size)
    assert_equal('b', @world.tb)
    assert_equal('b', @world.cs)
    assert_equal('c', @world.nn)
    
    @world.ms('c')
    assert_equal(0, @world.table.size)
    assert_equal(3, @world.stack.size)
    assert_equal('c', @world.tb)
    assert_equal('c', @world.cs)
    assert_nil(@world.nn)

  end
  
  def test_mt
    assert_equal(false, @world.mt('z') )

    @world.mt('a')
    assert_equal(0, @world.stack.size)
    assert_equal(3, @world.table.size)
    
    @world.ms('a')
    @world.ms('b')
    @world.ms('c')
    assert_empty(@world.table)
    assert_equal(3, @world.stack.size)
    assert_equal('abc', @world.stack.join)
    
    assert(@world.mt('a'),'is not true')
    assert(@world.table.include? 'c')
    assert(@world.mt('a'),'is not true')
    assert(@world.table.include? 'b')
    assert(@world.mt('a'),'is not true')
    assert(@world.table.include? 'a')
    assert_empty(@world.stack)
    assert_nil(@world.cs)
    assert_nil(@world.tb)
    assert_equal('a', @world.nn)
  end
  
  def test_eq
    x = 'a'
    y = 'b'
    assert_equal(false, @world.eq(x, y))
    
    x = []
    y = []
    assert_equal(true, @world.eq(x, y))
    
    x = 'a'
    y = 'b'
    assert_equal(false, @world.eq(x, y))
    assert_equal(false, @world.eq(x.to_s, y.to_s))

    x = 'c'
    y = 'c'
    assert_equal(true, @world.eq(x.to_s, y.to_s))
  end
  
  def test_not
    x = false
    result = @world.not(x)
    assert(result, 'did not return true')
    
    x = []
    result = @world.not(x)
    assert(result, 'did not return true')    

    x = nil
    result = @world.not(x)
    assert(result, 'did not return true')
    
    x = 'a'
    result = @world.not(x)
    assert_equal(false, result)

    x = ['a']
    result = @world.not(x)
    assert_equal(false, result)
  end
  
  def test_du
    test_class = Du_test.new
    test_class.call_me_true
    assert(test_class.check_me)
    
    x = test_class
    y = test_class
    assert( @world.du(x, y) )
  end
  
  def test_program
    assert_equal(1,@world.programs.size)
  end
  
  def display
    puts ''
    puts "Stack " + @world.stack.inspect
    puts "Table " + @world.table.inspect
  end
  
end