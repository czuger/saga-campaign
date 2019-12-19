class CreateLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :logs do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :data, null: false

      t.timestamps
    end
  end
end
