require 'date'
require 'json'
DREAMHOST_ACCESS_PATTERN = /\A(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (.+) (.+) \[(\d+\/\w+\/\d{4}:\d{2}:\d{2}:\d{2} [+-]\d{4})\] "(.+)" (\d{3}) (\d+) "(.*)" "(.*)"/
# Example:
# 108.66.243.211 - - [28/Jul/2017:06:11:30 -0700] "GET /assets/application-8b1ceb81717e5d3ee7c8b54e131350fa7f4dc5b25b4870d851b79ee345d86fac.css HTTP/1.1" 200 21866 "http://vitasa.abandonedfactory.net/signup" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36" 
class ApacheAccessLine
    attr_accessor :client_ip, :timestamp, :method, :path, :protocol, :status, :response_bytes, :referrer, :useragent

    def self.parse(line)
        match_groups = line.strip.match(DREAMHOST_ACCESS_PATTERN).captures
        a = ApacheAccessLine.new
        a.client_ip = match_groups[0]
        a.timestamp = DateTime.strptime( match_groups[3], "%d/%b/%Y:%H:%M:%S %Z").to_time
        a.method, a.path, a.protocol = match_groups[4].split(' ')
        a.status = match_groups[5]
        a.response_bytes = match_groups[6].to_i
        a.referrer = (match_groups[7] == '-') ?  nil : match_groups[7]
        a.useragent = (match_groups[8] == '-') ?  nil : match_groups[8]
        return a
    end

    def to_h
        {
            :client_ip => @client_ip,
            :timestamp => @timestamp,
            :method => @method,
            :path => @path,
            :status => @status,
            :response_bytes => @response_bytes,
            :referrer => @referrer,
            :useragent => @useragent,
        }
    end
end

class MinuteReport
    attr_accessor :data

    def initialize
        @data = {}
    end

    def increment_request(timestamp, request_str, status)
        minute = timestamp.utc.strftime("%Y-%m-%dT%H:%M:00 %Z")
        unless @data.keys.include?(minute)
            @data[minute] = {}
        end
        unless @data[minute].keys.include?(request_str)
            @data[minute][request_str] = {}
        end

        @data[minute][request_str][status] = if @data[minute][request_str].keys.include?(status) 
            @data[minute][request_str][status] + 1
        else
            1
        end
    end
end

class ApacheParser
    attr_accessor :path
    attr_reader :data
    def initialize(path = File.join(__dir__, '..', 'data', 'apache'))
        @path = path
        @data = []
    end

    def parse
        File.foreach(@path) do |line|
            line_data = ApacheAccessLine.parse(line)
            puts JSON.pretty_generate(line_data.to_h)
            @data.push(line_data)
        end
    end

    def report_by_minute
        report = MinuteReport.new
        @data.each do |request|
            report.increment_request(request.timestamp, "#{request.method} #{request.path}", request.status)
        end

        return report
    end
end

if __FILE__ == $0
    # parser = ApacheParser.new(File.join(__dir__, '..', 'data', 'apache', 'access.log'))
    parser = ApacheParser.new('/home/vitasa/log/vitasa.abandonedfactory.net/http/access.log')
    parser.parse
    puts JSON.pretty_generate(parser.report_by_minute.data)
    File.open(File.join(__dir__, '..', '..', 'public', 'access.json'), 'w') do |f|
        f.puts JSON.pretty_generate(parser.report_by_minute.data)
    end
end
