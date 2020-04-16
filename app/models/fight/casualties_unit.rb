module Fight
  class CasualtiesUnit

    attr_reader :name, :units_lost
    def initialize( tmp_unit )
      @name = tmp_unit.name
      @weapon = tmp_unit.weapon
      @libe = tmp_unit.libe
      @units_lost = tmp_unit.initial_amount - tmp_unit.current_amount
      @remaining_units = tmp_unit.current_amount
    end

    def destroyed?
      @remaining_units == 0
    end

  end
end