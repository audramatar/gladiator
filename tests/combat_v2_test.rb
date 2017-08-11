require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CombatV2Test < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end

  def test_fight
    player_turn = true
    @mock.expect :call, "player", [player_turn] 
    @combat_session.stub(:start_combat, @mock) do
      @combat_session.fight!
    end
    assert(@mock.verify)
  end

  def test_start_combat
    player_turn = false
    hps_to_test = {"enemy" =>[10, 0], "player" =>[0, 10], "both" =>[0, 0]}
    hps_to_test.each_pair do |answer, hps|
      @combat_session.player_character.hp = hps[0]
      @combat_session.enemy.hp = hps[1]
      assert_equal(answer, @combat_session.start_combat(player_turn = false),
        "When the player's hp is #{hps[0]} and the enemy's hp is #{hps[1]}, the function should return '#{answer}'.")
    end

  end

  def test_combat_loop
    @combat_session.enemy.hp = 0
    player_turn = false
    @combat_session.combat_loop(player_turn)
    assert_equal(1, @combat_session.turn, 
      "When the enemy's hp starts at 0, the loop should only run once.")
  end

  def test_turn_based_combat
    player_turn = false

    with_stdin do |user|
      user.puts "1"
      @combat_session.enemy.hp = 100
      @combat_session.player_character.hp = 100
      @mock.expect :call, false, [false]
      @mock.expect :call, false, [true]
      @combat_session.stub(:combat_phase, @mock) do
        @combat_session.turn_based_combat(player_turn)
      end
    end
    assert(@mock.verify)

    @combat_session.enemy.hp = 0
    assert(@combat_session.turn_based_combat(player_turn), 
      "When the enemy has 0 HP, the function turn_based_combat should return true.")
  end

  def test_combat_phase
    @mock.expect :call, nil, [false]
    @combat_session.stub(:initiate_correct_turn, @mock) do
      @combat_session.combat_phase(false)
    end

    @mock.expect :call, false, [@player_character.hp, @enemy.hp]
    @combat_session.stub(:check_for_death, @mock) do
      @combat_session.combat_phase(false)
    end
    assert(@mock.verify)
  end

  def test_player_goes_first
    player_character_init = 10
    enemy_init = 5
    assert(@combat_session.player_goes_first?(player_character_init, enemy_init), 
      "When the player's initiative is higher than the enemy's, function should return true.")

    player_character_init = 5
    enemy_init = 10
    assert(!@combat_session.player_goes_first?(player_character_init, enemy_init), 
      "When the player's initiative is lower than the enemy's, function should return false.")
  end

  def test_initiate_correct_turn
    @mock.expect :call, nil
    @combat_session.stub(:player_phase, @mock) do
      @combat_session.initiate_correct_turn(true)
    end

    @mock.expect :call, nil
    @combat_session.stub(:enemy_phase, @mock) do
      @combat_session.initiate_correct_turn(false)
    end
    assert(@mock.verify)
  end

  def test_who_is_dead
    hps_to_test = {"enemy" =>[10, 0], "player" =>[0, 10], "both" =>[0, 0]}
    hps_to_test.each_pair do |answer, hps|
      assert_equal(answer, @combat_session.who_is_dead(hps[0], hps[1]),
        "When the player's hp is #{hps[0]} and the enemy's hp is #{hps[1]}, the function should return '#{answer}'.")
    end
  end

  def test_check_for_death
    should_return_true = [[10, 0], [0, 10], [0, 0]]
    should_return_true.each do |hps|
      assert(@combat_session.check_for_death(hps[0], hps[1]),
        "When the player's hp is #{hps[0]} and the enemy's hp is #{hps[1]}, the function should return true.")
    end

    assert(!@combat_session.check_for_death(10, 10),
      "When the player's hp is above 0 and the enemy's hp is above 0, the function should return false.")
  end

end
