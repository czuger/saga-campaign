class CreateVictoryPointsHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :victory_points_histories do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :turn, limit: 1, null: false
      t.integer :points_total, limit: 1, null: false
      t.string :controlled_locations, null: false

      t.timestamps
    end

    add_column :campaigns, :turn, :integer, limit: 1, null: false, default: 1
    add_reference :campaigns, :winner, foreign_key: { to_table: :players }, index: false
  end
end
