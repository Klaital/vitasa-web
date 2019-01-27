json.extract! work_log, :id, :date, :hours, :approved
if work_log.site.nil?
  json.site ""
else
  json.site work_log.site.slug
end

