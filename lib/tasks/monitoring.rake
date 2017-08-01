namespace :monitoring do
  desc "Update a static data file describing the current system performance"
  task compile: :environment do
    current_log = "log/#{Rails.env}.log"
    puts "> Pulling from logfile #{current_log}"
    # find the most recent log line currently in the database. We'll only write records if the timestamp is newer
    newest_hit = SiteHit.last
    if newest_hit.nil?
      puts "> No hits in the database. Starting from scratch..."
    else
      puts "> Starting from #{newest_hit.timestamp.iso8601}"
    end
    new_record_count = 0

    File.foreach(current_log) do |line|
      # Parse the log line. If it's not JSON, skip it.
      # Dreamhost's Passenger implementation seems to forcibly prepend some data to Rails' log lines. Remove that if present.
      line.gsub!(/\A\w, \[.+\]  INFO -- : \[[\h-]+\] {/, '{')
      data = nil
      begin 
        data = JSON.load(line)
      rescue
        warn line
        print 'x'
        next
      end

      # Only write a record if it's new data
      if newest_hit.nil? || Time.parse(data['time']) > newest_hit.timestamp
        hit = SiteHit.new 
        hit.method = data['method']
        hit.path = data['path']
        hit.format = data['format']
        hit.controller = data['controller']
        hit.action = data['action']
        hit.status = data['status']
        hit.duration = data['duration']
        hit.view = data['view']
        hit.db = data['db']
        hit.timestamp = Time.parse(data['time'])
        hit.cookie = data['cookie']

        hit.save
        new_record_count += 1
        print '.'
      end
    end

    puts "\nAdded #{new_record_count} hits"
  end

end
