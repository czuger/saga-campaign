class AddMaintenanceRequiredToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :maintenance_required, :boolean, null: false, default: false
  end
end
