class AddEndpointToNotificationRegistration < ActiveRecord::Migration[5.0]
  def change
    add_column :notification_registrations, :endpoint, :string
  end
end
