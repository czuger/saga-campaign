class AddMaxPlayersToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :max_players, :integer, limit: 1, null: false, default: 2
  end
end
