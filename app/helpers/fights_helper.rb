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
  def pass_detail( pass_detail )
    attacker_name = Unit.long_name_from_log_data( pass_detail.attacker )

    "L'unité #{attacker_name} n'attaquera pas ce tour (#{pass_detail.attack_trigger}% de chances d'attaquer)."
  end

  def fight_detail( fight_detail )
    if fight_detail # If fight detail is nil then we are in the case of no retaliation

      attack_detail_string_dice_pool_part = t( '.attack_detail_string_dice_pool_part', count: fight_detail.dice_pool )
      attack_detail_string_hits_part = t( '.attack_detail_string_hits_part', count: fight_detail.hits )

      attack_translation = fight_detail.attack_phase == :attack ? '.attack_detail_string' : '.retailation_detail_string'

      attacker_name = Unit.long_name_from_log_data( fight_detail.attacker )
      defender_name = Unit.long_name_from_log_data( fight_detail.defender )

      attack = t( attack_translation, attacker_name: attacker_name, defender_name: defender_name,
                  attack_type_name: attack_type_name(fight_detail.attack_type),
                  dice_pool_part: attack_detail_string_dice_pool_part,
                  opponent_armor: fight_detail.opponent_armor,
                  hits_part: attack_detail_string_hits_part,
                  count: fight_detail.attacker.amount,
                  hits_rolls: fight_detail.hits_rolls)

      defense = t( '.defend_detail_string', defender_name: defender_name, opponent_save: fight_detail.opponent_save,
                   saves_rolls: fight_detail.saves_rolls, saves: fight_detail.saves, damages: fight_detail.damages,
                   count: fight_detail.defender.amount )

      attack.upcase_first + ' ' + defense.upcase_first
    end
  end

  def hits_detail( hit_detail )
    r = []

    hit_detail.each do |hit|
      name = Unit.long_name_from_log_data( hit.unit )

      if hit.type == :protection
        r << "#{name} a une protection. Elle prend #{hit.hits} touches et sa protection tombe à #{hit.after}."
      else
        r << "#{name} prend #{hit.hits} touches, perds #{hit.damages} figurines et se retrouve à #{hit.after}."
        r << "#{name} est détruite." if hit.unit_destroyed
      end
    end

    r.join( ' ' ).upcase_first
  end


  private

  def attack_type_name( attack_type )
    return 'par sortilège' if attack_type == :magic
    return 'à distance' if attack_type == :distance
    'au corps à corps'
  end
end
