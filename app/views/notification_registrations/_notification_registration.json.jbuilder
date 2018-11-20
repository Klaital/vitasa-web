json.extract! notification_registration, :id, :user_id, :token, :platform, :created_at, :updated_at
json.url notification_registration_url(notification_registration, format: :json)
