class AddInternationalCert < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.boolean :international_certification, default: false, null: false
    end
  end
end
