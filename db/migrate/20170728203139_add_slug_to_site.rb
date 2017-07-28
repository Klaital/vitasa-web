class AddSlugToSite < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :slug, :string
    add_index :sites, :slug
  end
end
