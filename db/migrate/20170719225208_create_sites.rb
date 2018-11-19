class CreateSites < ActiveRecord::Migration[5.0]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :latitude
      t.string :longitude
      t.integer :sitecoordinator
      t.string :sitestatus

      t.timestamps
    end
  end
end
