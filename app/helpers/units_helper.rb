module UnitsHelper

  def duplicate_link( unit )
    gang_units_path( unit.gang_id, unit: { libe: unit.libe,
                                   amount: unit.amount, points: unit.points, weapon: unit.weapon } )
  end

end
