class AddWinMethodToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :result, :string
  end
end
