class AddNotesToSites < ActiveRecord::Migration[5.0]
  def change
    change_table :sites do |t|
      t.string :contact_name
      t.string :contact_phone
      t.text :notes
    end
  end
end
