class AddOrganizationToUsersAndSites < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :slug, length: 64, null: false, unique: true
      t.string :name, length: 128, null: false
    end
    add_column :users, :organization_id, :integer
    add_column :sites, :organization_id, :integer
  end
end
