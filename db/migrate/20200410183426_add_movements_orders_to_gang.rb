class AddMovementsOrdersToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :movement_order, :integer
    add_column :gangs, :movements, :string
    add_column :gangs, :movements_backup, :string
    add_column :players, :movements_orders_finalized, :boolean, null: false, default: false
  end
end
