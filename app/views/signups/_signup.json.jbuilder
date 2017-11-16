json.extract! signup, :id, :created_at, :updated_at, :hours, :approved, :shift_id
json.site signup.shift.calendar.site.slug
json.site_name signup.shift.calendar.site.name
json.user signup.user.id
