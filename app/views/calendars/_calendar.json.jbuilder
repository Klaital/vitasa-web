json.extract! calendar, :id, :date, :is_closed, :backup_coordinator_today, :efilers_needed
json.open calendar.open.to_s
json.close calendar.close.to_s
