require 'minitest/autorun'
require_relative "../lib/factories/random_enemy_factory.rb"
require_relative "../lib/characters/enemies.rb"

class RandomEnemyTest < Minitest::Test
  def setup
    @random_enemy = Enemies.new
    @enemy_factory = RandomEnemyFactory.new
    @random_enemy = @enemy_factory.create_random_enemy(@random_enemy, 1)
  end

  def test_get_points_to_assign
    @enemy_factory.random_enemy.set_level(5)
    points = @enemy_factory.get_points_to_assign
    assert_equal(points, 21, "The random points were #{points}")

    level_groups = {20 => [1,2,3], 21 => [4, 5, 6, 7]}
    level_groups.each_pair do |answer, levels|
      levels.each do |level|
        @enemy_factory.random_enemy.set_level(level)
        assert_equal(answer, @enemy_factory.get_points_to_assign, 
                    "Given that enemy's level is #{level}, expected points to assign should be #{answer}")
      end
    end
  end
end