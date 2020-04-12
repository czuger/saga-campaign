module GameRules

  class Movements

    def initialize( campaign )
      @campaign = campaign
    end

    def run
      players = @campaign.players.order( :initative ).all
      @players_movements_hash = players.map{ |p| [ p.id, get_movements_array( p ) ] }

      until all_movements_done do
        players.each do |player|
         gang, movement = @players_movements_hash[ player.id ].shift
         puts "#{gang.name} move to #{movement}"
        end
      end
    end

    private

    def get_movements_array( player )
      result = []
      player.gangs.order( :movement_order ).each do |gang|
        result << [ gang, gang.get_next_movement! ]
      end
      result
    end

    def all_movements_done
      @players_movements_hash.values.map{ |e| e.count }.inject( &:+ ) == 0
    end

  end
end
