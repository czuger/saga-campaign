class AddNameToGang < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :name, :string
  end
end
