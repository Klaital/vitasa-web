class AggregatesController < ApplicationController
  # GET /schedule
  def schedule
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the next 1 week.
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today + 6
    dates_in_period = (period_start..period_end).map {|date| date}
    sites = params.has_key?('site') ? Site.where(slug: params['site']) : Site.all

    daily_schedule = {}
    dates_in_period.each {|d| daily_schedule[d] = []}

    sites.each do |site|
      dates_in_period.each do |date|
        # Find the calendar entry for today
        cal = Calendar.find_by(site_id: site.id, date: date)
        next if cal.nil? # Just exclude dates without a calendar entry

        # Compose the Schedule data
        site_schedule = {
          :slug => site.slug,
          :shifts => cal.shifts.collect {|shift|
            logger.debug("#{site.slug} @#{date}, Shift##{shift.id}")
            {
              :efilers_needed_basic => shift.efilers_needed_basic,
              :efilers_signed_up_basic => shift.efilers_signed_up('Basic'),
              :efilers_needed_advanced => shift.efilers_needed_advanced,
              :efilers_signed_up_advanced => shift.efilers_signed_up('Advanced'),
              :open => shift.start_time.to_s,
              :close => shift.end_time.to_s,
            }
          },
          :is_closed => cal.is_closed,
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

  def user_hours
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the past 1 week.
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today - 7
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today - 1
    # dates_in_period = (period_start..period_end).map {|date| date}

    @user_time_report = {}
    
    Signup.where(:date => period_start..period_end).each do |signup|
      @user_time_report[signup.user] = {:approved => 0.0, :total => 0.0} unless @user_time_report.has_key?(signup.user)
    
      @user_time_report[signup.user][:total] += signup.hours.to_f
      @user_time_report[signup.user][:approved] += signup.hours.to_f if signup.approved
    end
  end
end
