class AddDestroyedToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :gang_destroyed, :boolean, null: false, default: false
    add_column :gangs, :retreating, :boolean, null: false, default: false
  end
end
