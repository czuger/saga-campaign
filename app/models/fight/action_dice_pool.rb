module Fight

  class ActionDicePool

    attr_reader :band_exhausted

    def initialize( tmp_gang )
      @phoenix = 0
      @hammer = 0
      @tree = 0

      ad_count = count_actions_dice( tmp_gang )

      if ad_count > 0
        roll_and_dispatch_dice( ad_count )
      else
        @band_exhausted = true
      end
    end

    def to_s
      { phoenix: @phoenix, hammer: @hammer, tree: @tree}
    end

    def count_actions_dice( tmp_gang )
      [ tmp_gang.units.select{ |u| u.action_dice? }.count, 8 ].min
    end

    def roll_and_dispatch_dice( actions_dice_amout )
      p actions_dice_amout
      Hazard.from_string( "s#{actions_dice_amout}d6" ).rolls.each do |roll|
        case roll
          when 6
            @phoenix += 1
          when 4, 5
            @hammer += 1
          else
            @tree += 1
        end
      end
    end
  end

end