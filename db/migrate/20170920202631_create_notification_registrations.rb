class CreateNotificationRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_registrations do |t|
      t.integer :user_id
      t.string :token
      t.string :platform

      t.timestamps
    end
    add_index :notification_registrations, :user_id
  end
end
