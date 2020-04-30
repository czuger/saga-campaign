module GangsHelper

  def can_modify_gang?(unit )
    true || GameRules::Factions.recruitment_positions( unit.player ).include?( unit.location )
  end

end
