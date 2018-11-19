class AddPlaceIdToSites < ActiveRecord::Migration[5.0]
  def change
    change_table :sites do |t|
      t.string :google_place_id
    end
  end
end
