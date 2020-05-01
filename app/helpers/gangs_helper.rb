module GangsHelper

  def can_modify_gang?(unit )
    @campaign.aasm_state == 'troop_maintenance_required'.freeze || GameRules::Factions.recruitment_positions( unit.player ).include?( unit.location )
  end

end
