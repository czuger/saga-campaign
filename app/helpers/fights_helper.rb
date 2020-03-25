require 'ostruct'

module FightsHelper

  def new_combat_libe( gang )
    "#{gang.name} (#{gang.player.user.name})"
  end

  def participant_libe( attacker_name, band_no )
    "Bande n° #{band_no} de #{attacker_name}"
  end

  # Losses details

  # For fight log detail
  def pass_detail( log )
    c = OpenStruct.new( log )
    attacker_name = c.can_attack[:attacker]

    "L'unité #{attacker_name} n'attaquera pas ce tour (#{c.can_attack[:min_to_attack]}% de chances d'attaquer)."
    #" (elle a fait #{log[:can_attack][:roll]} et doit faire moins #{log[:can_attack][:min_to_attack]})."
  end

  def fight_detail( combat_info, attack_or_retaliation )
    c = OpenStruct.new( combat_info[:combat_result] )

    attack = OpenStruct.new( c[attack_or_retaliation] )
    attack_type = OpenStruct.new( attack.attack_type )
    attack_result = OpenStruct.new( attack.attack_result )

    if attack_or_retaliation == :retaliation
      ds = detail_string( c.defender.name, c.attacker.name, attack_or_retaliation,
                          attack_type, attack_result, c.attacker.amount,c.defender.amount )
    else
      ds = detail_string( c.attacker.name, c.defender.name, attack_or_retaliation,
                          attack_type, attack_result, c.attacker.amount, c.defender.amount )
    end

    ds
  end

  def hits_detail( log )
    h = OpenStruct.new( log[:combat_result][:hits_assignment] )
    r = []

    h.to_h.each do |k, v|
      name = k.to_s

      v = OpenStruct.new( v )

      if v.type == :protection
        r << "L'unité #{name} a une protection. Elle prend #{v.hits} touches et sa protection tombe à #{v.prot_after}."
      else
        r << "L'unité #{name} prend #{v.hits} touches, perds #{v.hits} figurines et se retrouve à #{v.amount_after}."
        r << "L'unité #{name} est détruite." if v.unit_destroyed
      end
    end

    r.join( ' ' ).upcase_first
  end


  private

  def detail_string( attacker_name, defender_name, attack_or_retaliation, attack_type, attack_result, attacker_amount, defender_amount )
    # "#{attacker_name} #{attack_name} #{defender_name} #{attack_type_name(attack_type)} avec #{attack_type.dice_pool} dés" +
    #   ", touche sur #{attack_type.opponent_armor}+ " +
    #   "et fait #{attack_result.hits_rolls} soit #{attack_result.hits} touches. " +
    #   "#{defender_name} sauvegarde sur #{attack_type.opponent_save}+ et lance #{attack_result.saves_rolls} soit #{attack_result.saves} sauvegardes. " +
    #   "Au final #{attack_result.damages} touches."

    attack_detail_string_dice_pool_part = t( '.attack_detail_string_dice_pool_part', count: attack_type.dice_pool )
    attack_detail_string_hits_part = t( '.attack_detail_string_hits_part', count: attack_result.hits )

    attack_translation = attack_or_retaliation == :attack ? '.attack_detail_string' : '.retailation_detail_string'

    attack = t( attack_translation, attacker_name: attacker_name, defender_name: defender_name,
                attack_type_name: attack_type_name(attack_type), dice_pool_part: attack_detail_string_dice_pool_part,
                opponent_armor: attack_type.opponent_armor, hits_part: attack_detail_string_hits_part,
                count: attacker_amount, hits_rolls: attack_result.hits_rolls)

    defense = t( '.defend_detail_string', defender_name: defender_name, opponent_save: attack_type.opponent_save,
                 saves_rolls: attack_result.saves_rolls, saves: attack_result.saves, damages: attack_result.damages,
                 count: defender_amount )

    attack.upcase_first + ' ' + defense.upcase_first
  end

  def attack_type_name( attack_type )
    return 'par sortilège' if attack_type.type == :magic
    return 'à distance' if attack_type.type == :distance
    'au corps à corps'
  end
end
