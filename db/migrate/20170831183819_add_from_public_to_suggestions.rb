class AddFromPublicToSuggestions < ActiveRecord::Migration[5.0]
  def change
    add_column :suggestions, :from_public, :boolean
  end
end
