class AggregatesController < ApplicationController

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
    
    WorkLog.where(:date => period_start..period_end).each do |work_log|
      @user_time_report[work_log.user] = {:approved => 0.0, :total => 0.0} unless @user_time_report.has_key?(work_log.user)

      hours = work_log.end_time - work_log.start_time
      @user_time_report[work_log.user][:total] += hours.to_f
      @user_time_report[work_log.user][:approved] += hours.to_f if work_log.approved
    end
  end
end
