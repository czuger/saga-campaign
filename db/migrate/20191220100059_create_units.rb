class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.references :gang, null: false, foreign_key: true
      t.string :libe, null: false
      t.integer :amount, null: false, limit: 1
      t.float :points, null: false

      t.timestamps
    end
  end
end
