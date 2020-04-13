class AddInitiativeBetToPlayer < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :initiative_bet, :integer
  end
end
