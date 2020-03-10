class AddLocationToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :location, :string
  end
end
