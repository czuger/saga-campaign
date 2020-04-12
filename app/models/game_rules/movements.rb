module GameRules

  class Movements

    def initialize( campaign )
      @campaign = campaign
    end

    def run!
      Campaign.transaction do
        @campaign.movements_results.delete_all

        players = @campaign.players.order( :initative ).all
        @players_movements_hash = Hash[ players.map{ |p| [ p.id, get_movements_array( p ) ] } ]

        until all_movements_done do
          players.each do |player|
            gang, movement = @players_movements_hash[ player.id ].shift

            @campaign.movements_results.create!(
              campaign: @campaign, player: player, gang: gang, from: gang.reload.location, to: movement )

            gang.location = movement
            gang.save!
          end
        end
      end
    end

    private

    def get_movements_array( player )
      result = []

      # pp player.gangs

      next_movement = true
      while next_movement
        player.gangs.order( :movement_order ).each do |gang|
          next_movement = gang.reload.get_next_movement!
          result << [ gang, next_movement ] if next_movement
        end
      end

      result
    end

    def all_movements_done
      @players_movements_hash.values.map{ |e| e.count }.inject( &:+ ) == 0
    end

  end
end
