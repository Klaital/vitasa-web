json.extract! site, :id, :name, :street, :city, :state, :zip, :latitude, :longitude, :sitecoordinator, :sitestatus, :created_at, :updated_at, :slug
json.url site_url(site, format: :json)