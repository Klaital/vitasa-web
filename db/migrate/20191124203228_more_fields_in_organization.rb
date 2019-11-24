class MoreFieldsInOrganization < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :authcode, :string, null: false, default: ''
    add_column :organizations, :contact, :string
    add_column :organizations, :phone, :string
    add_column :organizations, :email, :string
    add_column :organizations, :latitude, :float
    add_column :organizations, :longitude, :float
  end
end
