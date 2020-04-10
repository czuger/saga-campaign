class AddMovementsOrdersToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :movement_order, :integer
    add_column :gangs, :movement_1, :string
    add_column :gangs, :movement_2, :string
  end
end
