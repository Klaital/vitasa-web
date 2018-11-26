class AddActiveToSites < ActiveRecord::Migration[5.0]
  def change
    change_table :sites do |t|
      t.boolean :active, default: true
    end
  end
end
