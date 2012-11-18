require_relative 'world'
# main.rb
=begin
program2 = Node.new(:du)
mt_cs = Node.new(:mt, Node.new(:cs))
not_cs = Node.new(:not, Node.new(:cs))
program2.arg1 = mt_cs
program2.arg2 = not_cs

program3 = Node.new(:du)
ms_nn = Node.new(:ms, Node.new(:nn))
not_nn = Node.new(:not, Node.new(:nn))
program3.arg1 = ms_nn
program3.arg2 = not_nn

program = Node.new(:eq)
program.arg1 = program2
program.arg2 = program3    

@world = World.new(['a', 'b', 'c'], ['c'], ['b', 'a'], 0)
@world.add_program(program)

puts program.to_s
=end
@world = World.new(300)
@world.run