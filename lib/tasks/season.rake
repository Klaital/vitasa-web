require 'csv'
namespace :season do
  desc "Initialize the season given a config file in rails root called 'site_config.csv'"
  task init: :environment do
    season_start = Date.new(2018, 1, 16)
    season_end   = Date.new(2018, 4, 17)
    efilers_needed_basic = 5
    efilers_needed_advanced = 5

    lines_skipped = 0
    sites_updated = 0

    CSV.foreach(File.join(Rails.root, 'site_config.csv'), 'r') do |tokens|
      # Look up the site
      site = Site.find_by(slug: tokens[0])
      if site.nil?
        puts "\nSkipping Row: #{tokens[0]}"
        lines_skipped += 1
        next
      else
        puts "\nProcessing #{tokens[0]}:"
        sites_updated += 1
      end

      # Update the season dates for the site
      site.season_start = season_start
      site.season_end = season_end
      site.save

      calendars = (season_start..season_end).map do |date|
        # The site hours are in tokens 3 - 9
        hours = tokens[date.wday+3]

        # Upsert a calendar entry for today
        calendar = site.calendars.find_by(:date => date)
        calendar = site.calendars.create({:date => date}) if calendar.nil?

        # Dump any existing calendars, shifts and signups on the site
        calendar.shifts.delete_all

        # Set open/closed flag
        calendar.is_closed = (hours.nil? || hours.strip.empty?)
        calendar.save
        if calendar.is_closed
          puts "#{site.slug}, #{Date::DAYNAMES[date.wday]} #{date.iso8601}: CLOSED"
          next
        end

        # Parse the Time Of Day for the open and close times for the day overall        
        day_start, day_end = hours.split('-').map {|s| Tod::TimeOfDay.parse(s.strip)}
            
        # Split the day into 2-hour shifts, with the last one being 3 hours if the total is odd
        puts "#{Date::DAYNAMES[date.wday]} #{date}: #{day_start}-#{day_end}"
        shifts = []
        
        # I can't iterate neatly over DateTime ranges without casting to and from an integer, 
        # and that causes a loss of timezone awareness, which causes the values to be off by 
        # the timezone offset. 
        # Thus, we'll do old-fashioned iteration using a while loop and manually incrementing the
        # shift times.
        shift_start, shift_end = day_start.dup, day_start.dup + (3600*2)
        while(shift_start < day_end)
          shifts << Tod::Shift.new(shift_start, shift_end)
          shift_start += 3600*2
          shift_end += 3600*2
        end
        shifts.each_index do |shift_num|
          puts " > Shift ##{shift_num} #{shifts[shift_num].beginning}-#{shifts[shift_num].ending}"
        end

        # Ensure no shift is less than two hours long
        if shifts.length > 1 && shifts[-1].duration < (3600*2)
          last_shift = shifts.pop
          shifts[-1] = Tod::Shift.new(shifts[-1].beginning, last_shift.ending)
        end

        # I'm boring and like to watch lines scroll by while the job runs
        puts "#{site.slug}, #{Date::DAYNAMES[date.wday]} #{date.iso8601}: #{shifts.length} shifts from #{shifts[0].beginning} to #{shifts[-1].ending}"

        # Create the actual shift records
        calendar.shifts.create(shifts.map {|shift| 
          {
            :start_time => shift.beginning,
            :end_time => shift.ending,
            :efilers_needed_basic => efilers_needed_basic,
            :efilers_needed_advanced => efilers_needed_advanced,
          }
        })

        # End season date iteration    
      end
      # End CSV.foreach
    end
    # End task :init
  end
  # End namespace :season
end
