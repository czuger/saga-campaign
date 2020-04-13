module GameRules

  class Movements

    def initialize( campaign )
      @campaign = campaign
    end

    def run!
      Campaign.transaction do
        @campaign.movements_results.delete_all

        prepare_working_structures

        until all_movements_done? do

          @players.each do |p_struct|
            gang, movement = p_struct.movements_array.shift

            if gang
              @campaign.movements_results.create!(
                campaign: @campaign, player: p_struct.player, gang: gang, from: gang.location, to: movement )

              gang.location = movement
            end
          end
        end

        finalize_movements!
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

      # pp player.gangs

      next_movement = true
      while next_movement
        gangs.each do |gang|
          next_movement = gang.get_next_movement!
          result << [ gang, next_movement ] if next_movement
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

  end
end
