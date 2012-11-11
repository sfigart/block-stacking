require "test/unit"
require_relative 'node'
require_relative 'board'

class TestNode < Test::Unit::TestCase
  def setup
    @functions = {}
    @functions[:a] = 'a'
    @functions[:b] = 'b'
    @functions[:c] = 'c'
    @functions[:d] = 'd'
    @tree = Node.new(@functions[:a])
  end

  def setup_world
    goal =  'abc'
    stack = 'a'
    table = 'cb'
    @board = Board.new(goal, stack, table)
  end

  def test_initialize
    @tree.operation = @functions[:a]
  end
  
  def test_add_arg
    @child_node = Node.new(@functions[:b])
    @tree.arg1 = @child_node
    assert_equal(@child_node, @tree.arg1)

    @child_node2 = Node.new(@functions[:c])    
    @tree.arg2 = @child_node2
    assert_equal(@child_node2, @tree.arg2)
    
    @child_node3 = Node.new(@functions[:d])
    @node = @tree.arg1
    @node.arg1 = @child_node3
    assert_equal(@child_node3, @tree.arg1.arg1)  
  end
  
  def test_count
    assert_equal(1, @tree.count)

    @child_node = Node.new(@functions[:b])
    @tree.arg1 = @child_node
    assert_equal(2, @tree.count)

    @child_node2 = Node.new(@functions[:c])    
    @tree.arg2 = @child_node2
    assert_equal(3, @tree.count)

    @child_node3 = Node.new(@functions[:d])
    @node = @tree.arg2
    @node.arg1 = @child_node3
    assert_equal(4, @tree.count)    
  end
  
  def test_terminal_arg
    setup_world
    @node = Node.new(:cs)

    stack = @board.stack.clone
    table = @board.table.clone
    
    assert_nothing_raised do
      @node.execute(@board)
    end
    # Insure terminal arguments dont affect
    # state of the world
    assert_equal(stack, @board.stack)
    assert_equal(table, @board.table)
  end
  
  def test_execute_ms
    setup_world
    @node = Node.new(:ms)
    @node.arg1 = Node.new(:nn)
    
    assert_equal("b", @board.nn)
    assert_equal("a", @board.tb)
    assert_equal("a", @board.cs)
    
    @node.execute(@board)
    
    assert_equal("ab", @board.stack.join)
    assert_equal("c", @board.table.join)
  end
  
  def test_execute_mt
    setup_world
    @node = Node.new(:mt)
    @node.arg1 = Node.new(:tb)
    
    @node.execute(@board)
    
    assert_equal("", @board.stack.join)
    assert_equal("abc", @board.table.sort.join)
  end
  
  def test_execute_not
    setup_world
    @node = Node.new(:not)
    @node.arg1 = Node.new(:cs)
    
    result = @node.execute(@board)
    assert_equal(false, result)
    
    assert_equal("a", @board.stack.join)
    assert_equal("bc", @board.table.sort.join)
    
    # Remove the last item from the stack
    @node = Node.new(:mt)
    @node.arg1 = Node.new(:cs)

    @node.execute(@board)
    assert_equal("", @board.stack.join)
    
    # Stack is empty, so not cs should be true
    @node = Node.new(:not)
    @node.arg1 = Node.new(:cs)    
    result = @node.execute(@board)
    assert_equal(true, result)
  end

  def test_execute_not_ms_cs
    setup_world
    not_ms_cs = Node.new(:not, Node.new(:ms, Node.new(:cs)))
    assert_equal(true, not_ms_cs.execute(@board))
  end

  def test_execute_eq
    setup_world
    node = Node.new(:eq)
    # true condition
    node.arg1 = Node.new(:ms)
    node.arg1.arg1 = Node.new(:nn)
    # true condition
    node.arg2 = Node.new(:mt)
    node.arg2.arg1 = Node.new(:tb)
    
    assert( node.execute(@board) )   
    
    setup_world
    node = Node.new(:eq)

    #true condition
    ms_func = Node.new(:ms)
    ms_func.arg1 = Node.new(:nn)
    node.arg1 = ms_func
    
    # false condition
    not_func = Node.new(:not)
    not_func.arg1 = Node.new(:cs)
    node.arg2 = not_func    
    
    assert_equal(false, node.execute(@board) )   
  end
  
  def test_execute_du
    setup_world  
    mt_cs = Node.new(:mt)
    mt_cs.arg1 = Node.new(:cs)

    not_cs = Node.new(:not)
    not_cs.arg1 = Node.new(:cs)

    node = Node.new(:du, mt_cs, not_cs)
    
    assert( node.execute(@board) )
  end

  def test_to_s
    @node = Node.new(:ms)
    @node.arg1 = Node.new(:nn)
    
    assert_equal("ms (nn)", @node.to_s)

    @node = Node.new(:eq)
    @node.arg1 = Node.new(:ms)
    @node.arg1.arg1 = Node.new(:nn)
    
    @node.arg2 = Node.new(:mt)
    @node.arg2.arg1 = Node.new(:cs)    
    assert_equal("eq (ms (nn)), (mt (cs))", @node.to_s)
  end
  
  def test_leaf?
    node = Node.new(:nn)
    assert(node.leaf?)

    node = Node.new(:ms)
    node.arg1 = Node.new(:nn)
    assert_equal(false, node.leaf?)
  end
  
  def test_crossover
    tree1 = Node.new(:ms, Node.new(:cs))
    tree2 = Node.new(:mt, Node.new(:nn))
    puts "\ntree1 #{tree1}"
    puts "tree2 #{tree2}"
    child1, child2 = tree1.crossover(tree2)
    puts "child1 #{child1}"
    puts "child2 #{child2}"
    assert_not_equal(tree1.to_s, tree2.to_s)
    assert_not_equal(child1.to_s, child2.to_s)
  end
  
  def setup_tree
    @tree = Node.new(:du)
    mt_cs = Node.new(:mt, Node.new(:cs))
    not_cs = Node.new(:not, Node.new(:cs))
    @tree.arg1 = mt_cs
    @tree.arg2 = not_cs
  end
  
  def test_get_random_node
    setup_tree  
    node = @tree.get_random_node
    possible_nodes = @tree.dfs
    # Make sure the selected node was part of the tree
    assert(possible_nodes.include?(node))
  end

  def test_dfs
    setup_tree
    assert_equal(5, @tree.dfs.size)
  end
  
  def test_depth_count
    @tree = Node.new(:du)
    assert_equal(1, @tree.depth_count)
    
    mt_cs = Node.new(:mt, Node.new(:cs))
    @tree.arg1 = mt_cs
    assert_equal(2, @tree.depth_count)
    
    not_cs = Node.new(:not, Node.new(:cs))
    @tree.arg2 = not_cs
    assert_equal(2, @tree.depth_count)
    
    eq_op = Node.new(:eq, Node.new(:cs), Node.new(:cs))
    @tree.arg2.arg2 = eq_op
    assert_equal(3, @tree.depth_count)
  end

end