class CreatePreferredSites < ActiveRecord::Migration[5.0]
  def change
    create_table :preferred_sites do |t|
      t.integer :user_id
      t.integer :site_id
      t.timestamps
    end
  end
end
