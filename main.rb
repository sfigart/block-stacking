require_relative 'world'

# Change these values ---------------------------------------------
program_count    = 300
board_file       = 'boards2.csv'
crossover_rate   = 0.9
mutation_rate    = 0.1
generation_limit = 51
# -----------------------------------------------------------------

@world = World.new(program_count,
                   board_file,
                   crossover_rate,
                   mutation_rate,
                   generation_limit)

# Display properties
@world.properties.keys.sort.each do |key|
  puts "#{key}: #{@world.properties[key]}"
end

# Run the world
@world.run
