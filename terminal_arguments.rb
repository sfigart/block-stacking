#-------------------  
# Terminal Arguments
#-------------------
module TerminalArguments
  # top block
  def cs
    @stack.last
  end
  
  # top correct block
  def tb
    top_block = nil
    
    for i in 0..@stack.size - 1
      if @stack[i] == @goal[i]
        top_block = @stack[i]
      else
        top_block = @stack[i-1] if i > 0   # Return previous stack entry
        break
      end
    end
    return top_block
  end
  
  # next needed
  def nn
    for i in 0..@stack.size - 1
      if @stack[i] == @goal[i]
        next
      else
        return @goal[i] # stack at this index is different from goal
      end
    end
    @goal[@stack.size] # stack is smaller than the goal
  end
end