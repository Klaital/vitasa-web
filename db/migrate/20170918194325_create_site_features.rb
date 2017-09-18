class CreateSiteFeatures < ActiveRecord::Migration[5.0]
  def change
    create_table :site_features do |t|
      t.integer :site_id
      t.string :feature

      t.timestamps
    end
    add_index :site_features, :site_id
    add_index :site_features, :feature
  end
end
