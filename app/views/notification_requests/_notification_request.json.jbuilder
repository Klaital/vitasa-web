json.extract! notification_request, :id, :audience, :message, :sent, :message_id, :created_at, :updated_at
json.url notification_request_url(notification_request, format: :json)
