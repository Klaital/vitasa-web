json.extract! suggestion, :id, :subject, :details, :user_id, :created_at, :updated_at, :from_public
json.url suggestion_url(suggestion, format: :json)
