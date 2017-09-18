class AggregatesController < ApplicationController
  # GET /schedule
  def schedule
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the next 1 week.
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today + 6
    dates_in_period = (period_start..period_end).map {|date| date}

    daily_schedule = {}
    dates_in_period.each {|d| daily_schedule[d] = []}

    Site.all.each do |site|
      dates_in_period.each do |date|
        
        # What is the usual schedule for today?
        open = site.send("#{Date::DAYNAMES[date.wday].downcase}_open")
        close = open.nil? ? nil : site.send("#{Date::DAYNAMES[date.wday].downcase}_close")
        efilers_needed = open.nil? ? 0 : site.send("#{Date::DAYNAMES[date.wday].downcase}_efilers")
        is_closed = open.nil?

        # Is there an override for today?
        override = Calendar.find_by(site_id: site.id, date: date)
        unless override.nil?
            open = override.open
            close = override.close
            efilers_needed = override.efilers_needed
            is_closed = override.is_closed
        end

        site_schedule = {
          :slug => site.slug,
          :efilers_needed => efilers_needed,
          :efilers_signed_up => Signup.where(date: date, site_id: site.id).count,
          :is_closed => false,
          :open => open.nil? ? nil : open.strftime("%H:%M"),
          :close => close.nil? ? nil : close.strftime("%H:%M"),
        }
        if logged_in?
          site_schedule[:this_user_signup] = site.has_signup?(current_user, date)
        end
        daily_schedule[date] << site_schedule.dup
      end
    end

    @sites = []
    daily_schedule.each_pair do |date, schedule|
      @sites << {
        :date => date,
        :sites => schedule
      }
    end
  end

  def sites_status
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the next 1 week.
    @sites = {}
    Site.all.each do |site|
      # What is the usual schedule for today?
      open = site.send("#{Date::DAYNAMES[Date.today.wday].downcase}_open")
      close = open.nil? ? nil : site.send("#{Date::DAYNAMES[Date.today.wday].downcase}_close")
      efilers_needed = open.nil? ? 0 : site.send("#{Date::DAYNAMES[Date.today.wday].downcase}_efilers")
      is_closed = open.nil?

      # Is there an override for today?
      override = Calendar.find_by(site_id: site.id, date: Date.today)
      unless override.nil?
          open = override.open
          close = override.close
          efilers_needed = override.efilers_needed
          is_closed = override.is_closed
      end

      @sites[site] = {
        :open => open,
        :close => close,
        :is_closed => is_closed,
        :efilers_needed => efilers_needed,
        :efilers_volunteered => Signup.where('site_id = ? and date = ?', site.id, Date.today).count()
      }
    end
  end

end
