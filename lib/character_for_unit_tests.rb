require_relative "player_character.rb"

class CharacterForUnitTests < PlayerCharacter

  def initialize(name, race)
    super(name, race)
  end

  def create_test_character
    @level = 3
    @str = 12 # affects sword/unarmed attack, cbm, cbm_def
    @dex = 18 # affects ac, cbm_def
    @con = 14 # affects hp
    @mag = 15 # affects mag_resist, mag_dc
    @cha = 16 # affects crowd and magic

    @one_hand_prof = 2
    @dual_wield_prof = 2
    @two_hand_prof = 3
    @magic_prof = 2
    @unarmed_prof = 1
    @available_proficiency_points = 2
    @available_attribute_points = 4
    @max_proficency = 10

    calculate_initial_stats

    add_spell_to_known_spells("cure light wounds", @full_spell_list["cure light wounds"])
    add_spell_to_known_spells("magic missle", @full_spell_list["magic missle"])
    add_spell_to_known_spells("beguiler's grace", @full_spell_list["beguiler's grace"])
    add_spell_to_known_spells("shock weapon", @full_spell_list["shock weapon"])
    add_spell_to_known_spells("ray of sickening", @full_spell_list["ray of sickening"])

    add_item("bronze sword", @items.item_list["bronze sword"])
    add_item("bronze dual swords", @items.item_list["bronze dual swords"])
    add_item("health potion", @items.item_list["health potion"])
    add_item("bronze shield", @items.item_list["bronze shield"])

    @equipped_weapon = @inventory["bronze sword"]

    calculate_auto_attack
  end
end