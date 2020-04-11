module PlayersHelper

  def available_movements( gang_location )
    gang_location ? GameRules::Map.available_movements( gang_location ).sort : []
  end
end
