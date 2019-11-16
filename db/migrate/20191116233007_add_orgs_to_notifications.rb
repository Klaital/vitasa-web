class AddOrgsToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notification_requests, :organization_id, :integer, null: false, default: 1
  end
end
