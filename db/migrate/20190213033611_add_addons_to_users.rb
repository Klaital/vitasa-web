class AddAddonsToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.boolean :hsa_certification
      t.boolean :military_certification
    end
  end
end
