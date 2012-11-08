require 'logger'

class Node
  attr_accessor :operation, :arg1, :arg2
  def initialize(operation, arg1=nil, arg2=nil)
    @log = Logger.new(STDOUT)
    @log.level = Logger::DEBUG
    
    @operation = operation
    @arg1 = arg1
    @arg2 = arg2
  end
  
  def count
    sum = 0
    sum += @arg1.count if @arg1
    sum += @arg2.count if @arg2
    return 1 + sum
  end
  
  def crossover(other)
    return nil, nil if self.leaf? || other.leaf?
    
    # Deep clone self and other
    child1 = deep_clone
    child2 = other.deep_clone
        
    child1_node = child1.get_random_node
    child2_node = child2.get_random_node
    
    @log.debug "child1 #{child1.inspect}"
    @log.debug "child2 #{child2.inspect}"
    @log.debug "child1_node #{child1_node.inspect}"
    @log.debug "child2_node #{child2_node.inspect}"

    # Swap by attribute to keep parent object references intact
    child1_node.operation, child2_node.operation = child2_node.operation, child1_node.operation
    child1_node.arg1,      child2_node.arg1      = child2_node.arg1,      child1_node.arg1
    child1_node.arg2,      child2_node.arg2      = child2_node.arg2,      child1_node.arg2
    
    @log.debug "after swap"
    @log.debug "child1_node #{child1_node.inspect}"
    @log.debug "child2_node #{child2_node.inspect}"
    @log.debug "child1 #{child1.inspect}"
    @log.debug "child2 #{child2.inspect}"

    return child1, child2
  end
  
  def execute(board)
    case @operation
    when :cs, :tb, :nn # Terminal arguments, do nothing
      nil
    when :ms, :mt, :not # One arg functions, execute these
      method = board.method(@operation)
      arg1   = board.method(@arg1.operation)
      method.call( arg1.call )
    when :eq
      method = board.method(@operation)
      method.call( @arg1.execute(board), @arg2.execute(board) )
    when :du
      method = board.method(@operation)
      #  :du must repeatedly call arg1 and arg2
      method.call( @arg1, @arg2 )
    end    
  end
  
  def node?
    return false if arg1.nil? && arg2.nil?
    true
  end
  
  # No args
  def leaf?      
    return true if arg1.nil? && arg2.nil?
    false
  end

  def to_s
    output = ''
    output << @operation.to_s
    output << " (#{@arg1})" if arg1
    output << ", (#{@arg2})" if arg2
    output
  end

  def marshal_dump
    [@operation, @arg1, @arg2]
  end
  
  def marshal_load(array)
    @operation, @arg1, @arg2 = array
  end
  
  def node_type
    case @operation
    when :cs, :tb, :nn
      :terminal
    when :ms, :mt, :not
      :one_arg
    when :du, :eq
      :two_args
    end
  end

  #private
  
  def get_random_node
    dfs.sample
  end
    
  # Convert tree into a dfs array
  def dfs
    nodes = [self]
    nodes.concat( arg1.dfs ) if arg1
    nodes.concat( arg2.dfs ) if arg2
    nodes
  end
    
  def deep_clone
    Marshal::load(Marshal.dump(self))
  end
end