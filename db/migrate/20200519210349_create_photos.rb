class CreatePhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :photos do |t|

      t.references :player, null: false, foreign_key: true
      t.references :fight_result, null: false, foreign_key: true

      t.string :comment
      t.string :filename, null: false

      t.timestamps
    end
  end
end
