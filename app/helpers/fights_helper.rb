require 'ostruct'

module FightsHelper

  def participant_libe( attacker_name, band_no )
    "Bande n° #{band_no} de #{attacker_name}"
  end

  # For fight log detail
  def pass_detail( log )
    c = OpenStruct.new( log )
    attacker_name = @game_rules_units.name_from_string_key( c.attacker )

    "L'unité #{attacker_name} n'attaquera pas ce tour."
    #" (elle a fait #{log[:can_attack][:roll]} et doit faire moins #{log[:can_attack][:min_to_attack]})."
  end


  def fight_detail( combat_info, attack_or_retaliation )
    c = OpenStruct.new( combat_info )
    attacker_name = @game_rules_units.name_from_string_key( c.attacker )
    defender_name = @game_rules_units.name_from_string_key( c.defender )

    attack = OpenStruct.new( c.combat_result[attack_or_retaliation] )
    attack_type = OpenStruct.new( attack.attack_type )
    attack_result = OpenStruct.new( attack.attack_result )

    attack_name = :attaque
    attack_name = 'riposte contre' if attack_or_retaliation == :retaliation

    if attack_or_retaliation == :retaliation
      detail_string( defender_name, attacker_name, attack_name, attack_type, attack_result )
    else
      detail_string( attacker_name, defender_name, attack_name, attack_type, attack_result )
    end
  end

  def hits_detail( log )
    h = OpenStruct.new( log[:combat_result][:hits_assignment] )

    p h.to_h
    r = []

    h.to_h.each do |k, v|
      p k, v
      name = @game_rules_units.name_from_string_key( k.to_s )

      v = OpenStruct.new( v )

      if v.type == :protection
        r << "L'unité #{name} a une protection. Elle prend #{v.hits} touches et sa protection tombe à #{v.prot_after}."
      else
        r << "L'unité #{name} prend #{v.hits} touches, perds #{v.hits} figurines et se retrouve à #{v.amount_after}."
        r << "L'unité #{name} est détruite." if v.unit_destroyed
      end
    end

    r.join( ' ' )
  end


  private

  def detail_string( attacker_name, defender_name, attack_name, attack_type, attack_result )
    "#{attacker_name} #{attack_name} #{defender_name} #{attack_type_name(attack_type)} avec #{attack_type.dice_pool} dés" +
      ", touche sur #{attack_type.opponent_armor}+ " +
      "et fait #{attack_result.hits_rolls} soit #{attack_result.hits} touches. " +
      "#{defender_name} sauvegarde sur #{attack_type.opponent_save}+ et lance #{attack_result.saves_rolls} soit #{attack_result.saves} sauvegardes. " +
      "Au final #{attack_result.damages} touches."
  end

  def attack_type_name( attack_type )
    return 'par sortilège' if attack_type.type == :magic
    return 'à distance' if attack_type.type == :distance
    'au corps à corps'
  end
end
