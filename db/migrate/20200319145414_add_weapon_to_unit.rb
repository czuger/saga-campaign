class AddWeaponToUnit < ActiveRecord::Migration[6.0]
  def change
    Unit.delete_all

    add_column :units, :weapon, :string
    change_column :units, :weapon, :string, :null => false
  end
end
