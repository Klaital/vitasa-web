json.extract! site, :id, :name, :slug,
    :street, :city, :state, :zip, :latitude, :longitude, :google_place_id,
    :sitecoordinator, 
    :sitestatus,
    :monday_open,
    :monday_close,
    :tuesday_open,
    :tuesday_close,
    :wednesday_open,
    :wednesday_close,
    :thursday_open,
    :thursday_close,
    :friday_open,
    :friday_close,
    :saturday_open,
    :saturday_close,
    :sunday_open,
    :sunday_close

json.url site_url(site.slug, format: :json)

json.calendar_overrides site.calendars, partial: 'calendars/calendar', as: :calendar
# json.calendar_overrides site.calendars, :id, :date, :open, :close, :is_closed
