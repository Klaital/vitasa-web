json.extract! role_grant, :id, :user_id, :role_id, :created_at, :updated_at
json.url role_grant_url(role_grant, format: :json)