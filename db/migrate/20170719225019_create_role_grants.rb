class CreateRoleGrants < ActiveRecord::Migration[5.0]
  def change
    create_table :role_grants do |t|
      t.belongs_to :role, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
