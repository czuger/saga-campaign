module UnitsHelper

  def duplicate_link( unit )
    gang_units_path( unit.gang_id, unit: { libe: unit.libe,
                                   amount: unit.amount, points: unit.points, weapon: unit.weapon } )
  end

  def number_field_options( edition )
    { class: 'form-control', placeholder: 'Nombre de figurines', min: @unit_data[:min], max: @unit_data[:max],
      step: edition ? 1 : @unit_data[:step] }
  end

  def options_for_vue( options_in )
    raw"<option v-for='option in #{options_in}' v-bind:value='option.id'>
      {{ option.text }}
    </option>"
  end

  def readonly_select?
  end

  def disabled_class
    'disabled' unless @can_add_units
  end

end
