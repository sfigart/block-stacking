#------------------  
# Program Generator
#------------------
module ProgramGenerator
  def generate_random_program(max_depth=4)
    @max_depth = max_depth
    
    functions = [:ms, :mt, :not, :du, :eq]
    function_name = functions.sample
    @log.debug "generate_random_program #{function_name}"
    
    case function_name
    when :ms, :mt, :not
      build_one_arg_function(function_name)
    when :du, :eq
      depth = 0
      build_two_arg_function(function_name, depth)
    end
  end
  
  def build_one_arg_function(function_name)
    @log.debug "build_one_arg_function #{function_name}"
    function = Node.new(function_name)
    function.arg1 = Node.new([:cs, :tb, :nn].sample)

    function
  end

  def build_two_arg_function(function_name, depth)
    @log.debug "build_two_arg_function #{function_name}, depth #{depth}"
    return if depth >= @max_depth - 1
    
    @log.debug("arg1")
    arg1 = build_arg_function(depth)
    @log.debug("arg2")
    arg2 = build_arg_function(depth)
    
    function = Node.new(function_name)
    function.arg1 = arg1
    function.arg2 = arg2
    
    function
  end
  
  def build_arg_function(depth)
    @log.debug "build_arg_function depth #{depth}"
    if rand(2) == 1
      build_one_arg_function( [:ms, :mt, :not].sample )
    else
      build_two_arg_function( [:du, :eq].sample, depth+1 )
    end
  end
end