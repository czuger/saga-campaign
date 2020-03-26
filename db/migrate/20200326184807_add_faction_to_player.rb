class AddFactionToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :faction, :string
  end
end
