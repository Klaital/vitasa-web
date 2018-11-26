json.extract! site, :id, :name, :slug,
    :street, :city, :state, :zip, :latitude, :longitude, :google_place_id,
    :season_start, :season_end,
    :active

json.sitecoordinators site.coordinators, partial: 'users/sc_details', as: :user

json.url site_url(site.slug, format: :json)

json.calendar_overrides site.calendars, partial: 'calendars/calendar', as: :calendar
json.work_log site.work_history

json.site_features site.site_features.collect {|feature| feature.feature}

