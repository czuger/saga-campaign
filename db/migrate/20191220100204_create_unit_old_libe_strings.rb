class CreateUnitOldLibeStrings < ActiveRecord::Migration[6.0]
  def change
    create_table :unit_old_libe_strings do |t|
      t.references :gang, null: false, foreign_key: true
      t.string :libe, null: false

      t.timestamps
    end
  end
end
