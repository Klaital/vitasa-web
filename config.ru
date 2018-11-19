# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require 'rack-statsd'
statsd = Statsd.new(Rails.env.production? ? '34.210.183.223' : 'localhost', 8125).tap{|sd| sd.namespace = "vitasa.#{Rails.env}"}
use RackStatsD::ProcessUtilization, "", "", {:stats => statsd}
run Rails.application
