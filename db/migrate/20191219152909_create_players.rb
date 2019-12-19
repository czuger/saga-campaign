class CreatePlayers < ActiveRecord::Migration[6.0]
  def change
    create_table :players do |t|

      t.references :campaign, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :pp, null: false, default: 0
      t.integer :god_favor
      t.integer :god_favored

      t.timestamps
    end
  end
end
