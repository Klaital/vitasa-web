class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :slug
      t.text :text

      t.timestamps
    end
    add_index :resources, :slug
  end
end
