require_relative 'logging'

class Node
  include Logging
  
  attr_accessor :operation, :arg1, :arg2
  attr_reader   :du_iteration_count, :du_iteration_limit
  
  def initialize(operation, arg1=nil, arg2=nil)  
    @operation = operation
    @arg1 = arg1
    @arg2 = arg2
    
    @du_iteration_count = 0
    @du_iteration_limit = 10
  end
  
  def depth_count
    left = right = 0
    left  += @arg1.depth_count if @arg1 && ![:cs, :tb, :nn].include?(@arg1.operation)
    right += @arg2.depth_count if @arg2 && ![:cs, :tb, :nn].include?(@arg2.operation)

    return 1 + [left, right].max
  end
  
  def count
    sum = 0
    sum += @arg1.count if @arg1
    sum += @arg2.count if @arg2
    return 1 + sum
  end
  
  def crossover(other)
    logger.info("node.crossover")
    
    logger.debug("  crossover self : #{self.to_s}")
    logger.debug("  crossover other: #{other.to_s}")
    # Deep clone self and other
    child1 = deep_clone
    child2 = other.deep_clone

    logger.debug("  crossover child1: #{child1.to_s}")
    logger.debug("  crossover child2: #{child2.to_s}")
        
    child1_node = child1.get_random_node
    child2_node = child2.get_random_node
    
=begin    
    logger.debug "child1 #{child1.inspect}"
    logger.debug "child2 #{child2.inspect}"
    logger.debug "child1_node #{child1_node.inspect}"
    logger.debug "child2_node #{child2_node.inspect}"
=end
    # Swap by attribute to keep parent object references intact
    child1_node.operation, child2_node.operation = child2_node.operation, child1_node.operation
    child1_node.arg1,      child2_node.arg1      = child2_node.arg1,      child1_node.arg1
    child1_node.arg2,      child2_node.arg2      = child2_node.arg2,      child1_node.arg2
    
=begin    
    logger.debug "after swap"
    logger.debug "child1_node #{child1_node.inspect}"
    logger.debug "child2_node #{child2_node.inspect}"
=end
    logger.debug "  child1 #{child1}"
    logger.debug "  child2 #{child2}"

    return child1, child2
  end
  
  def execute(board)
    case @operation
    when :cs, :tb, :nn # Terminal arguments, do nothing
      nil
      
    when :ms, :mt, :not # One arg functions, execute these
      method = board.method(@operation)
      if [:cs, :tb, :nn].include?(@arg1.operation)
        arg1   = board.method(@arg1.operation)
        method.call( arg1.call ) 
      else
        method.call(@arg1.execute(board))
      end
    
    when :eq
      method = board.method(@operation)
      method.call( @arg1.execute(board), @arg2.execute(board) )
    
    when :du
      return true if @du_iteration_count >= @du_iteration_limit
      @du_iteration_count += 1
      method = board.method(@operation)
      #  :du must repeatedly call arg1 and arg2
      method.call( @arg1, @arg2 )
    end  
  end

  def to_s
    output = ''
    output << @operation.to_s
    output << " (#{@arg1})" if arg1
    output << ", (#{@arg2})" if arg2
    output
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
  
  # Cloning Methods  
  def deep_clone
    Marshal::load(Marshal.dump(self))
  end
  
  def marshal_dump
    [@operation, @arg1, @arg2]
  end
  
  def marshal_load(array)
    initialize(*array)
  end
end