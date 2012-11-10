#--------------------  
# Primitive Functions
#--------------------
module PrimitiveFunctions  
  # move to stack
  def ms(x)
    index = @table.index(x)
    if index
      @stack.push @table.delete_at(index)
      true
    else
      false
    end
  end
  
  # move to table
  def mt(x)
    if @stack.include?(x)
      @table.push @stack.pop
      return true
    end
    false
  end
  
  # returns T if x=F, else returns F
  def not(x)
    return true if x == false || x.nil? || x.empty?
    return false
  end
  
  # returns T if x equals y, and returns F otherwise
  def eq(x, y)
    x == y
  end
  
  # executes the expression x repeatedly until expression y returns the value T
  def du(x, y)
    counter =0
    result = false
    while (!result) do
      @log.debug("counter b: #{counter}")
      x.execute(self)
      result = y.execute(self)
      counter += 1
      @log.debug("counter a: #{counter}")
      break if counter > 25 # Prevent infinite loop
    end
    
    @log.debug("broke out of loop: #{counter}") if counter > 25

    result
  end
end