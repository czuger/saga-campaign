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
    attacker_name = Unit.short_name_from_log_data( pass_detail.attacker )

    t( '.pass_details_string', name: attacker_name, attack_trigger: pass_detail.attack_trigger )
  end

  def fight_detail( fight_detail )
    if fight_detail # If fight detail is nil then we are in the case of no retaliation

      attack_detail_string_dice_pool_part = t( '.attack_detail_string_dice_pool_part', count: fight_detail.dice_pool )
      attack_detail_string_hits_part = t( '.attack_detail_string_hits_part', count: fight_detail.hits )

      attack_phase = t( '.attack_phase.' + fight_detail.attack_phase.to_s )

      attacker_name = Unit.short_name_from_log_data( fight_detail.attacker )
      defender_name = Unit.short_name_from_log_data( fight_detail.defender )

      attack = t( '.attack_detail_string', attacker_name: attacker_name, defender_name: defender_name,
                  attack_type_name: attack_type_name(fight_detail.attack_type),
                  dice_pool_part: attack_detail_string_dice_pool_part,
                  opponent_armor: fight_detail.opponent_armor,
                  hits_part: attack_detail_string_hits_part,
                  attacker_count: fight_detail.attacker.amount, defender_count: fight_detail.defender.amount,
                  hits_rolls: fight_detail.hits_rolls, attack_phase: attack_phase )

      defend_detail_string_hits_part = t( '.attack_detail_string_hits_part', count: fight_detail.damages )
      defend_detail_string_saves_part = t( '.defend_detail_string_saves_part', count: fight_detail.saves )

      defense = t( '.defend_detail_string', defender_name: defender_name, opponent_save: fight_detail.opponent_save,
                   saves_rolls: fight_detail.saves_rolls, saves_string: defend_detail_string_saves_part,
                   hits_part: defend_detail_string_hits_part )

      attack.upcase_first + ' ' + defense.upcase_first
    end
  end

  def hits_detail( hit_detail )
    r = []

    hit_detail.each do |hit|
      name = Unit.short_name_from_log_data( hit.unit )

      defend_detail_string_hits_part = t( '.attack_detail_string_hits_part', count: hit.hits )

      if hit.type == :protection
        r << t( '.hit_protection_string', name: name, hits: hit.hits, before: hit.before, after: hit.after,
                hits_part: defend_detail_string_hits_part )
      else
        defend_detail_string_casualties_part = t( '.defend_detail_string_casualties_part', count: hit.damages )

        r << t( '.hit_loss_string', name: name, hits: hit.hits, damages: hit.damages, before: hit.before,
                after: hit.after, hits_part: defend_detail_string_hits_part, casualties_part: defend_detail_string_casualties_part )
        # r << "L'unité #{name} prend #{hit.hits} touches, perds #{hit.damages} figurines et passe de #{hit.before} à #{hit.after}."
        r << t( '.hit_destroyed_string', name: name ) if hit.unit_destroyed
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
