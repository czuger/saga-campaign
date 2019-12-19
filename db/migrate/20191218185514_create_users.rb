class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false, unique: true, index: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
