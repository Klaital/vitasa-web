json.extract! site, :id, :name, :slug,
    :street, :city, :state, :zip, :latitude, :longitude, :google_place_id,
    :sitecoordinator, 
    :sitestatus,
    :monday_efilers, :tuesday_efilers, :wednesday_efilers, 
    :thursday_efilers, :friday_efilers, :saturday_efilers, :sunday_efilers,
    :season_start, :season_end

json.sitecoordinator_name User.find(site.sitecoordinator).name unless site.sitecoordinator.nil?
json.monday_open site.monday_open.to_s
json.monday_close site.monday_close.to_s
json.tuesday_open site.tuesday_open.to_s
json.tuesday_close site.tuesday_close.to_s
json.wednesday_open site.wednesday_open.to_s
json.wednesday_close site.wednesday_close.to_s
json.thursday_open site.thursday_open.to_s
json.thursday_close site.thursday_close.to_s
json.friday_open site.friday_open.to_s
json.friday_close site.friday_close.to_s
json.saturday_open site.saturday_open.to_s
json.saturday_close site.saturday_close.to_s
json.sunday_open site.sunday_open.to_s
json.sunday_close site.sunday_close.to_s

json.backup_coordinator site.backup_coordinator_id
json.backup_coordinator_name User.find(site.backup_coordinator_id).name unless site.backup_coordinator_id.nil?

json.url site_url(site.slug, format: :json)

json.calendar_overrides site.calendars, partial: 'calendars/calendar', as: :calendar

json.work_history Signup.where('site_id = :site_id AND date < :date', {:site_id => site.id, :date => Date.today}), 
                    partial: 'signups/signup', 
                    as: :signup

json.work_intents Signup.where('site_id = :site_id AND date >= :date', {:site_id => site.id, :date => Date.today}), 
                    partial: 'signups/signup', 
                    as: :signup


json.site_features site.site_features.collect {|feature| feature.feature}
