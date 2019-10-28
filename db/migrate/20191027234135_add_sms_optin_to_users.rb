class AddSmsOptinToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sms_optin, :boolean, default: false, null: false
  end
end
