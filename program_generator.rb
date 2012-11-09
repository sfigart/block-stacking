#------------------  
# Program Generator
#------------------
module ProgramGenerator
  def generate_random_program
    functions = [:ms, :mt, :not, :eq, :du]
    function_name = functions.sample
    
    case function_name
    when :ms, :mt, :not
      build_one_arg_function(function_name)
    when :eq, :du
      build_two_arg_function(function_name)
    end
  end
  
  def build_one_arg_function(function_name)
    function = Node.new(function_name)
    function.arg1 = Node.new([:cs, :tb, :nn].sample)

    function
  end

  def build_two_arg_function(function_name)
    arg1 = build_arg_function
    arg2 = build_arg_function
    
    function = Node.new(function_name)
    function.arg1 = arg1
    function.arg2 = arg2
    
    function
  end
  
  def build_arg_function
    if rand(2) == 1
      build_one_arg_function( [:ms, :mt, :not].sample )
    else
      build_two_arg_function( [:du, :eq].sample )
    end
  end
end