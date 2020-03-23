module GameRules

  # This class is used only to count points and give a result at the end of the game
  #
  # @param attacker_gang [Gang] the gang of the attacker.
  # @param defender_gang [Gang] the gang of the defender.
  # @param body_count [Hash] the list of the losses of the fight.
  class FightAttackCountPoints

    attr_reader :attacker_points_list, :attacker_points_total, :defender_points_list, :defender_points_total
    attr_reader :winner, :winner_code

    def initialize( attacker_gang, defender_gang, body_count )
      @body_count = body_count

      @attacker_gang = attacker_gang
      @defender_gang = defender_gang
    end

    def do
      @attacker_points_list, @attacker_points_total = compute_result_for @attacker_gang
      @defender_points_list, @defender_points_total = compute_result_for @defender_gang

      if @attacker_points_total >= 8 && @attacker_points_total > @defender_points_total + 3

        @winner = @attacker_gang.player.user.name
        @winner_code = :attacker

      elsif @defender_points_total >= 8 && @defender_points_total > @attacker_points_total + 3

        @winner = @defender_gang.player.user.name
        @winner_code = :defender

      else

        @winner = 'Egalité'
        @winner_code = :equality

      end

      # As the object will be saved as an YAML object in log it is better to remove ActiveRecord items (they are huge and useless).
      @attacker_gang = nil
      @defender_gang = nil
      @body_count = nil

      self
    end

    private

    # Compute points given by each loss or destroyed units.
    #
    # @param opponent [Gang] the attacker.
    #
    # @return [Array] Strings to be printed in the fight log
    # @return [Integer] The total of the points earned
    def compute_result_for( opponent )
      total = 0
      points_list = []

      opponent.units.each do |unit|
        if @body_count.has_key?( unit.id )
          bc = OpenStruct.new( @body_count[ unit.id ] )
          points = ( bc.deads * unit.massacre_points ).to_i

          points_list << "L'unité #{unit.full_name} a eu #{bc.deads} pertes ce qui donne give #{points} points."
          total += points

          if bc.destroyed == true
            if unit.legendary?
              points = 4
            else
              points = 1
            end

            points_list << "La destruction de l'unité #{unit.full_name} donne #{points} extra points."
            total += points
          end
        end
      end

      return points_list, total
    end
  end

end
