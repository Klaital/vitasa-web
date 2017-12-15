class AggregatesController < ApplicationController

  # GET /schedule
  def schedule
    # Set the time period to look at the site and volunteer schedule for
    # Default is to examine the next 1 week.
    period_start = params.has_key?('start') ? Date.parse(params['start']) : Date.today
    period_end   = params.has_key?('end') ? Date.parse(params['end']) : Date.today + 6

    # Check for a cached version of the schedule
    @schedule = $redis.get("sites_data_#{period_start}-#{period_end}")
    if @schedule.nil?
      logger.info("No cached schedule for #{period_start} - #{period_end}")

      dates_in_period = (period_start..period_end).map {|date| date}
      sites = params.has_key?('site') ? Site.where(slug: params['site']) : Site.all

      daily_schedule = {}
      dates_in_period.each {|d| daily_schedule[d] = []}

      # Eager load the relevant calendars, shifts, and signups
      @sites = Site.all
      @calendars = Calendar.find_by_sql([
        "SELECT * FROM calendars WHERE date BETWEEN ? AND ?",
        period_start, period_end
      ])
      @shifts = Shift.find_by_sql([
        "SELECT * FROM shifts INNER JOIN calendars ON calendars.id = shifts.calendar_id WHERE calendars.date BETWEEN ? AND ? ",
        period_start, period_end
      ])
      @signups = Signup.find_by_sql([
        "SELECT * FROM signups INNER JOIN shifts ON shifts.id = signups.shift_id INNER JOIN calendars ON calendars.id = shifts.calendar_id WHERE calendars.date BETWEEN ? AND ?",
        period_start, period_end
      ])

      # Initialize the data structure
      @sites_data = {}
      # Each date in the range should have an entry, where each site's shifts will be listed
      dates_in_period.each do |date| 
        logger.debug("Initializing @sites_data[#{date}]")
        @sites_data[date] = {
          'date' => date.iso8601, 
          'is_closed' => true,
          'sites' => {}
        }
      end

      # Populate the shifts
      @shifts.each do |shift|
        #TODO: mark the site as not closed for the day if the calendar entry says so
      
        # Initialize the site entry if needed
        unless @sites_data[shift.calendar.date]['sites'].has_key?(shift.calendar.site.slug)
          @sites_data[shift.calendar.date]['sites'][shift.calendar.site.slug] = {
            'slug' => shift.calendar.site.slug,
            'shifts' => {},
            'is_closed' => shift.calendar.is_closed
          }
          @sites_data[shift.calendar.date]['sites'][shift.calendar.site.slug]['this_user_signup'] = false if logged_in?
        end
      
        # Add this shift record
        @sites_data[shift.calendar.date]['sites'][shift.calendar.site.slug]['shifts'][shift.start_time.to_s] = {
          'open' => shift.start_time.to_s,
          'close' => shift.end_time.to_s,
          'efilers_needed_basic' => shift.efilers_needed_basic,
          'efilers_signed_up_basic' => 0,
          'efilers_needed_advanced' => shift.efilers_needed_advanced,
          'efilers_signed_up_advanced' => 0,
        }
      end

      # Populate the Volunteers Signup Counts
      @signups.each do |signup|
        logger.debug("Analyzing signup #{signup.id}, for the #{signup.shift.start_time} shift on #{signup.shift.calendar.date} at #{signup.shift.calendar.site.slug}")

        # Determine whether the logged-in user has signed up to work this shift
        if logged_in?
          if signup.user_id == current_user.id
            @sites_data[signup.shift.calendar.date]['sites'][signup.shift.calendar.site.slug]['this_user_signup'] = true
          end
        end

        advanced_increment = signup.user.certification == 'Advanced' ? 1 : 0
        basic_increment = signup.user.certification == 'Basic' ? 1 : 0

        logger.debug("@sites_data: #{@sites_data.nil?}")
        logger.debug("@sites_data[#{signup.shift.calendar.date}]: #{@sites_data[signup.shift.calendar.date].nil?}")
        @sites_data[signup.shift.calendar.date]['sites'][signup.shift.calendar.site.slug]['shifts'][signup.shift.start_time.to_s]['efilers_signed_up_basic'] += basic_increment
        @sites_data[signup.shift.calendar.date]['sites'][signup.shift.calendar.site.slug]['shifts'][signup.shift.start_time.to_s]['efilers_signed_up_advanced'] += advanced_increment
    end

      @schedule = []
      @sites_data.each_pair do |date, date_data|
      
        schedule_entry = {
          'date' => date,
          'sites' => date_data['sites'].map {|slug, site_data| {
            'slug' => slug,
            'is_closed' => site_data['is_closed'].nil? ? site_data['shifts'].length == 0 : site_data['is_closed'],
            'this_user_signup' => (site_data.has_key?('this_user_signup') ? site_data['this_user_signup'] : nil),
            'shifts' => site_data['shifts'].values,
          }.compact}
        }
        @schedule << schedule_entry
      end
      $redis.set("sites_data_#{period_start}-#{period_end}", JSON.generate(@schedule))
    else
      logger.info("Read schedule from cache")
      @schedule = JSON.parse(@schedule)
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
