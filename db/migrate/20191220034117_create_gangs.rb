class CreateGangs < ActiveRecord::Migration[6.0]
  def change
    create_table :gangs do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.string :icon

      t.timestamps
    end
  end
end
