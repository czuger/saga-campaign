class AddCampaignModeToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :campaign_mode, :string, null: false
  end
end
