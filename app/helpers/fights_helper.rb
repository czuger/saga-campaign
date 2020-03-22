require 'ostruct'

module FightsHelper

  def participant_libe( attacker_name, band_no )
    "Bande n° #{band_no} de #{attacker_name}"
  end

  # For fight log detail
  def fight_detail( combat_info )
    c = OpenStruct.new( combat_info )
    attacker_name = @game_rules_units.name_from_string_key( c.attacker )
    defender_name = @game_rules_units.name_from_string_key( c.defender )

    attack = OpenStruct.new( c.combat_result[:attack] )
    attack_type = OpenStruct.new( attack.attack_type )
    attack_result = OpenStruct.new( attack.attack_result )

    "#{attacker_name} attaque #{defender_name} #{attack_type_name(attack_type)} avec #{attack_type.dice_pool} dés et touche sur #{attack_type.opponent_armor}+ " +
      "Il fait #{attack_result.hits_rolls} soit #{attack_result.hits} touches. " +
      "#{defender_name} sauvegarde sur #{attack_type.opponent_save}+ et lance #{attack_result.saves_rolls} soit #{attack_result.saves} sauvegardes. " +
      "Au final #{attack_result.damages} touches."
  end

  private

  def attack_type_name( attack_type )
    return 'par sortilège' if attack_type.type == :magic
    return 'à distance' if attack_type.type == :distance
    'au corps à corps'
  end
end
