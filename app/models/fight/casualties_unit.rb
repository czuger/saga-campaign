module Fight
  class CasualtiesUnit

    attr_reader :name, :units_lost, :remaining_units, :original_unit_id, :destroyed, :recover_to

    def initialize( tmp_unit )
      @name = tmp_unit.name
      @weapon = tmp_unit.weapon
      @libe = tmp_unit.libe
      @units_lost = tmp_unit.initial_amount - tmp_unit.current_amount
      @remaining_units = tmp_unit.current_amount
      @amount = tmp_unit.amount
      @original_unit_id = tmp_unit.original_unit_id
      @destroyed = tmp_unit.destroyed?
      @recover_to = tmp_unit.recover_to
      @final_losses = tmp_unit.final_losses
    end

  end
end