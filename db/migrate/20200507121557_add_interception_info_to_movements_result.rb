class AddInterceptionInfoToMovementsResult < ActiveRecord::Migration[6.0]
  def change
    add_column :movements_results, :interception_info, :string
    add_reference :movements_results, :intercepted_gang, foreign_key: { to_table: :gangs }

    remove_column :movements_results, :interception, :string
    add_column :movements_results, :interception, :boolean, null: false, default: true
    remove_column :movements_results, :interception_info, :string

    add_column :units, :losses, :integer, limit: 2

  end
end
