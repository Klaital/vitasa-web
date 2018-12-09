class AddSubsribeMobileToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :subscribe_mobile, :boolean
  end
end
