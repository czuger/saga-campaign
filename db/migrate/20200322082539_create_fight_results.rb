class CreateFightResults < ActiveRecord::Migration[6.0]
  def change
    create_table :fight_results do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :location, null: false
      t.string :fight_data, null: false
      t.string :fight_log, null: false

      t.timestamps
    end
  end
end
