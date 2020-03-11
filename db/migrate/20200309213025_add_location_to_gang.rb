class AddLocationToGang < ActiveRecord::Migration[6.0]
  def up
    # This is required so that sqlite accept NOT NULL migration
    add_column :gangs, :location, :string
    change_column :gangs, :location, :string, :null => false

    add_column :gangs, :faction, :string
    change_column :gangs, :faction, :string, :null => false
  end

  def down
    remove_column :gangs, :location
    remove_column :gangs, :faction
  end

end
