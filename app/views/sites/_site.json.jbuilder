json.extract! site, :id, :name, :slug, :organization_id,
    :street, :city, :state, :zip, :latitude, :longitude, :google_place_id,
    :season_start, :season_end,
    :contact_name, :contact_phone,
    :notes, :active

json.sitecoordinators site.coordinators, partial: 'users/sc_details', as: :user
json.url site_url(site.slug, format: :json)

json.calendar_overrides site.calendars, partial: 'calendars/calendar', as: :calendar
json.work_log site.work_history, partial: 'work_logs/work_log', as: :work_log

json.site_features site.site_features.collect {|feature| feature.feature}
