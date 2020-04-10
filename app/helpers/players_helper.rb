module PlayersHelper

  def available_movements( gang )
    GameRules::Map.available_movements( gang.location ).sort
  end
end
