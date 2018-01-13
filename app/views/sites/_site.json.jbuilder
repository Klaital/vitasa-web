json.extract! site, :id, :name, :slug,
    :street, :city, :state, :zip, :latitude, :longitude, :google_place_id,
    :sitecoordinator, 
    :sitestatus,
    :season_start, :season_end

json.sitecoordinator_name User.find(site.sitecoordinator).name unless site.sitecoordinator.nil?

json.backup_coordinator site.backup_coordinator_id
json.backup_coordinator_name User.find(site.backup_coordinator_id).name unless site.backup_coordinator_id.nil?

json.url site_url(site.slug, format: :json)

json.calendar_overrides site.calendars, partial: 'calendars/calendar', as: :calendar
#json.work_history site.work_history
#json.work_intents site.work_intents

json.site_features site.site_features.collect {|feature| feature.feature}

