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
    logger.debug("mt  #{x}")
    if @stack.include?(x)
      @table.push @stack.pop
      return true
    end
    false
  end
  
  # returns T if x=F, else returns F
  def not(x)
    return !x if x.is_a?(TrueClass || x.is_a?(FalseClass))
    return true if x == false || x.nil? || x.empty?
    return false
  end
  
  # returns T if x equals y, and returns F otherwise
  def eq(x, y)
    logger.debug("eq")
    logger.debug("  x: #{x} nil? #{x.nil?}")
    logger.debug("  y: #{y} nil? #{y.nil?}")

    x == y
  end
  
  # executes the expression x repeatedly until expression y returns the value T
  def du(x, y)
    logger.debug("du")
    logger.debug("  x: #{x}")
    logger.debug("  y: #{y}")
    counter =0
    result = false
    while (!result) do
      x.execute(self)
      result = y.execute(self)
      logger.debug "  result is #{result}"
      counter += 1
      
      # Prevent infinite loop
      if counter > 25
        result = true
        break
      end
    end
    result
  end
end