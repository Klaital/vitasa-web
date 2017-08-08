json.extract! calendar, :id, :date, :is_closed
json.open calendar.open.to_s
json.close calendar.close.to_s
