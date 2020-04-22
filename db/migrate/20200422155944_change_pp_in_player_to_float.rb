class ChangePpInPlayerToFloat < ActiveRecord::Migration[6.0]
  def change
    change_column :players, :pp, :float
  end
end
