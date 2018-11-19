namespace :perf do
  desc "Do a complete performance test, and return the report"
  task :run => :environment do 
    log_dir = File.join(__dir__, '..','..', 'log')
    logfiles = Dir.glob(File.join(log_dir, 'perf-*.log'))
    logfiles.each {|f| File.delete(f)}

    pids = []
    4.times do
      pids.push( spawn('bundle exec rails perf:test[100,8]') )
    end
    pids.each {|p| Process.wait(p)}
    Rake::Task['perf:report'].invoke
  end

  desc "Parse the peformance test logs, and generate a report describing the results"
  task :report => :environment do
    log_dir = File.join(__dir__, '..','..', 'log')
    logfiles = Dir.glob(File.join(log_dir, 'perf-*.log'))

    report = {
      :total_request_count => 0,
      :test_start_time => nil,
      :test_finish_time => nil,
      :endpoint => {
        'GET /sites' => {
          :codes => {
            '200' => 0,
            '400' => 0,
          },
          :time => {
            :min => 2147483647,
            :max => 0,
            :mean => 0,
            :data => []
          }
        }
      }
    }

    logfiles.each do |logname|
      File.open(logname, 'r') do |log|
        while(line=log.gets)
          data = JSON.parse(line)
          data['timestamp'] = Time.parse(data['timestamp'])
          unless report[:endpoint].has_key?(data['resource'])
            report[:endpoint][data['resource']] = {
              :codes => {},
              :time => {:min => 2147483647, :max => 0, :mean => 0, :data => []},
            }
          end
          unless report[:endpoint][data['resource']][:codes].has_key?(data['status'])
            report[:endpoint][data['resource']][:codes][data['status']] = 0
          end
          if report[:test_start_time].nil?
            report[:test_start_time] = data['timestamp']
            report[:test_finish_time] = data['timestamp']
          end

          
          report[:endpoint][data['resource']][:codes][data['status']] += 1
          report[:endpoint][data['resource']][:time][:data].push(data['runtime'])
          report[:total_request_count] += 1
          report[:test_start_time] = data['timestamp'] if report[:test_start_time].to_f > data['timestamp'].to_f
          report[:test_finish_time] = data['timestamp'] if report[:test_finish_time].to_f < data['timestamp'].to_f
        end
      end
    end

    # Per-endpoint analysis.
    report[:endpoint].each_key do |resource|
      total_runtime = 0.0
      report[:endpoint][resource][:time][:data].compact.each do |t| 
        total_runtime += t
        report[:endpoint][resource][:time][:min] = t if report[:endpoint][resource][:time][:min] > t
        report[:endpoint][resource][:time][:max] = t if report[:endpoint][resource][:time][:max] < t
      end
      report[:endpoint][resource][:time][:mean] = total_runtime / report[:endpoint][resource][:time][:data].count
    end

    # TPS analysis
    seconds_elapsed = report[:test_finish_time] - report[:test_start_time]
    report[:overall_tps] = report[:total_request_count] / seconds_elapsed.round
    report[:endpoint].each_key do |resource|
      report[:endpoint][resource][:time].delete(:data)
    end
    puts JSON.pretty_generate(report)
  end

  desc "Run a multi-threaded performance test, spamming a single HTTP request at a time"
  task :test, [:count, :threads] => :environment do |t, args|
    require 'net/http'
    hostname = {
      'development' => 'http://localhost:3000',
      'staging' => 'http://vitasa.klaital.com',
      'production'  => 'http://vitasa.abandonedfactory.net'
    }
    selected_hostname = hostname[Rails.env]
    http_requests = [
      {
        :hostname => selected_hostname,
        :endpoint => '/sites',
      },
      {
        :hostname => selected_hostname,
        :endpoint => '/sites.json',
      },
      {
        :hostname => selected_hostname,
        :endpoint => '/sites/1',
      },
      {
        :hostname => selected_hostname,
        :endpoint => '/sites/1.json',
      }
    ]

    threads = []
    args[:threads].to_i.times do |thread_num|
      t = Thread.new do
        log = File.open(File.join(__dir__, '..', '..', 'log', "perf-#{Process.pid}-#{thread_num}.log"), 'w')
        
        args[:count].to_i.times do |i|
          config = http_requests.sample
          request_resource = "#{config[:hostname]}#{config[:endpoint]}"
          uri = URI(request_resource)
          req_start = Time.now
          res = Net::HTTP.get_response(uri)
          req_end = Time.now
          # if res.is_a?(Net::HTTPSuccess)
          #   print '.'
          # else
          #   print 'x'
          # end

          log.puts({
            :resource => "GET #{config[:endpoint]}",
            :request => request_resource,
            :status => res.code,
            :runtime => ((req_end.to_f - req_start.to_f) * 1000).round,
            :timestamp => req_start
          }.to_json)
        end
        log.close
      end
      threads.push(t)
    end
    threads.each {|t| t.join}

  end

end
