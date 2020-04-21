module GameRules

  class Movements

    def initialize( campaign )
      @campaign = campaign
      @intercepted_gang_ids = Set.new
    end

    def run!
      Campaign.transaction do
        @campaign.movements_results.delete_all

        prepare_working_structures

        until all_movements_done? do

          @players.each do |p_struct|
            gang, movement = p_struct.movements_array.shift

            if gang
              next if gang.retreating
              next if @intercepted_gang_ids.include?( gang.id )

              original_location = gang.location

              gang.location = movement
              intercepted_gang, interception_result = check_for_interception!( gang )

              mr = @campaign.movements_results.create!(
                campaign: @campaign, player: p_struct.player, gang: gang, from: original_location, to: movement,
                interception: interception_result )

              if intercepted_gang
                result = Fight::Base.new( @campaign.id, movement, gang.id,
                                         intercepted_gang.id, movement_result: mr ).go

                if result.result.winner_code == :attacker
                  intercepted_gang.retreat!( @campaign )
                else
                  gang.retreat!( @campaign )
                end

                check_for_retreat!( gang )
                check_for_retreat!( intercepted_gang )
              end

              control_point!( movement, p_struct.player, result )
            end
          end
        end

        gain_and_loose_pp!  # Need to be before because finalize movement save data
        finalize_movements!

        @campaign.players_bet_for_initiative!
      end
    end

    private

    def prepare_working_structures
      @players = []
      @gangs = []

      @campaign.players.includes( :gangs, :user ).order( :initiative ).each do |player|
        ps = OpenStruct.new( player: player, movements_array: nil, gangs:
          player.gangs.order( :movement_order ).to_a )
        @players << ps

        @gangs += ps.gangs
        backup_movements!( ps.gangs )

        ps.movements_array = get_movements_array( ps.gangs )
      end
    end

    def get_movements_array( gangs )
      result = []

      next_movement_found = true
      while next_movement_found
        next_movement_found = false

        gangs.each do |gang|
          next_movement = gang.movements.shift
          result << [ gang, next_movement ] if next_movement

          next_movement_found ||= next_movement
        end
      end

      result
    end

    def backup_movements!( gangs )
      gangs.each do |gang|
        gang.movements_backup = OpenStruct.new(
          scheduled_movements: gang.movements.dup, original_location: gang.location )
      end
    end

    def finalize_movements!
      @players.each do |p_struct|
        p_struct.player.movements_orders_finalized = false
        p_struct.player.save!
      end
      @gangs.each do |gang|
        gang.save!
      end
    end

    def all_movements_done?
      @players.map{ |e| e.movements_array.count }.flatten.inject(&:+ ) == 0
    end

    def control_point!( location, new_controller, result )
      # The control change only if the winner is the attacker.
      # In case the attack fail or in case of equality, the control remain unchanged.
      if result&.result&.winner_code == :attacker
        @players.each do |p_struct|
          p_struct.player.controls_points.delete( location )
        end

        @campaign.logs.create!( data: I18n.t( 'log.gangs.take_control', name: new_controller.name, location: location ) )

        new_controller.controls_points << location unless new_controller.controls_points.include?( location )
      end
    end

    # This will probably moved elsewhere
    def gain_and_loose_pp!
      map = GameRules::Map.new

      @players.each do |p_struct|
        player = p_struct.player

        total_pp = player.controls_points.map{ |control| map.position_value( control ) }.inject( &:+ )
        player.pp += total_pp
        @campaign.logs.create!( data: I18n.t( 'log.pp.control_points_gain', name: player.user.name, count: total_pp ) )

        maintenance = ( player.gangs.sum( :points ) * 0.5 ).ceil
        player.pp -= maintenance
        @campaign.logs.create!( data: I18n.t( 'log.pp.maintenance_loss', name: player.user.name, count: maintenance ) )
      end
    end

    def check_for_interception!( intercepting_gang )
      intercepted_gang = @gangs.reject{ |g| g.player_id == intercepting_gang.player_id }.select{ |g| g.location == intercepting_gang.location }.first

      if intercepted_gang
        intercepted_gang.movements = []
        @intercepted_gang_ids << intercepted_gang.id

        intercepting_gang.movements = []
        @intercepted_gang_ids << intercepting_gang.id

        [
          intercepted_gang,
          I18n.t(
            'gangs.interception', intercepted_name: intercepted_gang.name, intercepting_name: intercepting_gang.name,
            location: intercepting_gang.location )
        ]
      end
    end

    def check_for_retreat!( gang )
      if gang.points < 4
        gang.retreat!( @campaign )
      end
    end

  end
end
