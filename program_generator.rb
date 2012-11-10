#------------------  
# Program Generator
#------------------
module ProgramGenerator
  def generate_random_program(max_depth=4)
    @max_depth = max_depth
    
    functions = [:ms, :mt, :not, :du, :eq]
    function_name = functions.sample
    
    case function_name
    when :ms, :mt, :not
      build_one_arg_function(function_name)
    when :du, :eq
      depth = 0
      build_two_arg_function(function_name, depth)
    end
  end
  
  def build_one_arg_function(function_name)
    function = Node.new(function_name)
    function.arg1 = Node.new([:cs, :tb, :nn].sample)

    function
  end

  def build_two_arg_function(function_name, depth)
    # limit test
    if depth >= (@max_depth - 1)
      # Return 2 args of the same terminal operation
      arg1 = Node.new([:cs, :tb, :nn].sample)
      arg2 = Node.new(arg1.operation)
    else
      arg1 = build_arg_function(depth)
      arg2 = build_arg_function(depth)      
    end
    
    function = Node.new(function_name)
    function.arg1 = arg1
    function.arg2 = arg2
    
    function
  end
  
  def build_arg_function(depth)
    if rand(2) == 1
      build_one_arg_function( [:ms, :mt, :not].sample )
    else
      build_two_arg_function( [:du, :eq].sample, depth+1 )
    end
  end
end