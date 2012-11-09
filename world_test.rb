require "test/unit"

require_relative "world"

class TestWorld < Test::Unit::TestCase

  def setup
    @world = World.new(1)
  end
  
  def test_initialize
    assert_equal(1, @world.programs.count)
    assert_equal(166, @world.boards.count)
  end
end