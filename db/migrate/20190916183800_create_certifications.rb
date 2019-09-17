class CreateCertifications < ActiveRecord::Migration[5.0]
  def change
    create_table :certifications do |t|
      t.integer :organization_id, null: false, index: true
      t.string :name, length: 64, null: false
      t.timestamps
    end

    create_table :certification_grants do |t|
      t.integer :certification_id, null: false
      t.integer :user_id, null: false, index: true
      t.timestamps
    end
  end
end
