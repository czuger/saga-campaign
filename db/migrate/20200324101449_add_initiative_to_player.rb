class AddInitiativeToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :initiative, :integer
  end
end
