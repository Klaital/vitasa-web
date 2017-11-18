json.extract! shift, :id, :efilers_needed_basic, :efilers_needed_advanced, :calendar_id, :day_of_week, :created_at, :updated_at

json.start_time shift.start_time.to_s
json.end_time shift.end_time.to_s

