class AddSubscriptionToNotificationRegistration < ActiveRecord::Migration[5.0]
  def change
    add_column :notification_registrations, :subscription, :string
  end
end
