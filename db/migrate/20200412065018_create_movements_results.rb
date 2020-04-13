class CreateMovementsResults < ActiveRecord::Migration[6.0]
  def change
    create_table :movements_results do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.references :gang, null: false, foreign_key: true
      t.string :from, null: false
      t.string :to, null: false
      t.string :interception
      t.string :fight

      t.timestamps
    end
  end
end
