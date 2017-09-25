class CreateNotificationRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_requests do |t|
      t.string :audience
      t.text :message
      t.datetime :sent
      t.string :message_id

      t.timestamps
    end
  end
end
