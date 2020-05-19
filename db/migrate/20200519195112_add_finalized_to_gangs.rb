class AddFinalizedToGangs < ActiveRecord::Migration[6.0]
  def change
    add_column :gangs, :finalized, :boolean, default: false, null: false
  end
end
