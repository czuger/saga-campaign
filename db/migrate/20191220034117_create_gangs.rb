class CreateGangs < ActiveRecord::Migration[6.0]
  def change
    create_table :gangs do |t|
      t.references :campaign, null: false, foreign_key: true, index: false
      t.references :player, null: false, foreign_key: true, index: false
      t.string :icon, null:false

      t.timestamps
    end

    add_index :gangs, [ :campaign, :player ], unique: true
  end
end
