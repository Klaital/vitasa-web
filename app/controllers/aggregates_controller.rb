class AggregatesController < ApplicationController
  # GET /schedule
  def schedule
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the next 1 week.
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today + 6
    dates_in_period = (period_start..period_end).map {|date| date.iso8601}

    @sites = []
    Site.all.each do |site|


      site_schedule = {
        :slug => site.slug,
        :efilers_needd => 0,
        :efilters_signed_up => 2,
        :is_closed => false,
        :open => '',
        :close => '',
      }
      if logged_in?
        site_schedule[:this_user_signup] = false
      end
    end



  end
end
