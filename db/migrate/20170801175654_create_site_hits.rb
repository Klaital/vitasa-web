class CreateSiteHits < ActiveRecord::Migration[5.0]
  def change
    create_table :site_hits do |t|
      t.string :method
      t.string :path
      t.string :format
      t.string :controller
      t.string :action
      t.integer :status
      t.float :duration
      t.float :view
      t.float :db
      t.datetime :timestamp
      t.string :cookie

      t.timestamps
    end
  end
end
