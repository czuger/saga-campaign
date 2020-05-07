class AddInterceptionInfoToMovementsResult < ActiveRecord::Migration[6.0]
  def change
    add_column :movements_results, :interception_info, :string

    remove_column :movements_results, :interception, :string
    add_column :movements_results, :interception, :boolean, null: false, default: true
  end
end
