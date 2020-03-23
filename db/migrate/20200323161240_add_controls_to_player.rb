class AddControlsToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :controls_points, :string
  end
end
