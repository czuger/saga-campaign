module Fight
  class CasualtiesUnit

    attr_reader :name, :units_lost, :remaining_units
    def initialize( tmp_unit )
      @name = tmp_unit.name
      @weapon = tmp_unit.weapon
      @libe = tmp_unit.libe
      @units_lost = tmp_unit.initial_amount - tmp_unit.current_amount
      @remaining_units = tmp_unit.current_amount
      @amount = tmp_unit.amount
    end

    def destroyed?
      @remaining_units == 0
    end

    def recover_to
      if @units_lost > 0 && !destroyed?
        half_amount = @amount / 2.0
        ( ( @remaining_units / half_amount ).ceil * half_amount ).to_i
      end
    end

  end
end