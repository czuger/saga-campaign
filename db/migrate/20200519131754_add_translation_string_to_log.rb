class AddTranslationStringToLog < ActiveRecord::Migration[6.0]
  def change
    remove_column :logs, :data, :string

    add_column :logs, :category, :string, null: false, index: true
    add_column :logs, :translation_string, :string, null: false
    add_column :logs, :translation_data, :string
  end
end
