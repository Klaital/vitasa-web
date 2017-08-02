
Rails.application.configure do 
    config.statsd_enabled = true
    config.statsd = Statsd.new(Rails.env.production? ? '34.210.183.223' : 'localhost', 8125).tap{|sd| sd.namespace = "vitasa.#{Rails.env}"}
end
