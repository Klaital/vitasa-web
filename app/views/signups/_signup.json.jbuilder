json.extract! signup, :id, :date, :created_at, :updated_at, :hours, :approved
json.site signup.site.slug
json.user signup.user.id
