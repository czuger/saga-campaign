class AddMovementsOrdersToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :movement_order, :integer
    add_column :gangs, :movement_1, :string
    add_column :gangs, :movement_2, :string
    add_column :players, :movements_orders_finalized, :boolean, null: false, default: false
  end
end
