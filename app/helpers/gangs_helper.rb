module GangsHelper

  def can_modify_gang?(unit )
    @campaign.troop_maintenance_required? || @campaign.first_hiring_and_movement_schedule? ||
      GameRules::Factions.recruitment_positions( unit.player ).include?( unit.location.to_sym )
  end

end
