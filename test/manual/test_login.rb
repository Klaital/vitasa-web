require 'net/http'
require 'json'
require 'logger'

logger = Logger.new('manual.log', 'daily')

host = "localhost:3000"

session_cookie = ""
uri = URI("http://#{host}/")
http = Net::HTTP.new(uri.host, uri.port)
http.set_debug_output(logger)

puts "> Login"
uri = URI("http://#{host}/login")
request = Net::HTTP::Post.new uri
request.body = {
    'email': 'kenkaku@gmail.com',
    'password': 'h0Shinokoe'
}.to_json
response = http.request(request)

puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
session_cookie = response['Set-Cookie']
puts ">> Body: #{response.body}"

if response.code !~ /[23]\d\d/
    exit(0)
end

puts "> Get Site #1"
uri = URI("http://#{host}/sites/1")
request = Net::HTTP::Get.new uri
request['Accept'] = 'application/json'

response = http.request(request)

puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
puts ">> Body: #{response.body}" if response['Content-Type'] == 'application/json'

if response.code != '200'
    exit(0)
end

puts "> Update Site Status"
uri = URI("http://#{host}/sites/1")
request = Net::HTTP::Patch.new uri
request['Cookie'] = session_cookie
request['Accept'] = 'application/json'
request['Content-Type'] = 'application/json'
request.body = {
    "zip": "78205"
}.to_json

response = http.request(request)

puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
puts ">> Content-Type: #{response['Content-Type']}"
if response['Content-Type'].include? 'application/json'
    puts ">> Body: #{response.body}" 
    puts JSON.pretty_generate(JSON.load(response.body))
end

if response.code !~ /20./
    exit(0)
end

puts "> Create New Site"
uri = URI("http://#{host}/sites/")
request = Net::HTTP::Post.new uri
request['Cookie'] = session_cookie
request['Accept'] = 'application/json'
request['Content-Type'] = 'application/json'
request.body = {
  "name": "Manual Test Login",
  "street": "300 Alamo Plaza",
  "city": "San Antonio",
  "state": "TX",
  "zip": "78206",
  "latitude": "29.425729",
  "longitude": "-98.486277",
  "sitecoordinator": nil,
  "sitestatus": "Closed",
}.to_json

response = http.request(request)

created_site_data = nil
puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
puts ">> Content-Type: #{response['Content-Type']}"
if response['Content-Type'].include? 'application/json'
    created_site_data = JSON.load(response.body)
    puts ">> Body: #{response.body}" 
    puts JSON.pretty_generate(created_site_data)
end

if response.code !~ /20./ || created_site_data.nil?
    exit(0)
end


puts "> Create a Calendar Override"
uri = URI("http://#{host}/sites/1/calendars/")
request = Net::HTTP::Post.new uri
request['Cookie'] = session_cookie
request['Accept'] = 'application/json'
request['Content-Type'] = 'application/json'
request.body = {"date": "2017-08-10", "open": "09:30:00", "close": "14:15:00", "is_closed":false, "notes": ""}.to_json
response = http.request(request)
puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
puts ">> Content-Type: #{response['Content-Type']}"
if response.body
    puts ">> Body: #{response.body}"
end

puts "> Delete The Site"
uri = URI("http://#{host}/sites/#{created_site_data['id']}")
request = Net::HTTP::Delete.new uri
request['Cookie'] = session_cookie
request['Accept'] = 'application/json'
request['Content-Type'] = 'application/json'

response = http.request(request)

puts ">> Got #{response.code} #{response.message}"
puts ">> Cookies: #{response['Set-Cookie']}"
puts ">> Content-Type: #{response['Content-Type']}"
if response.body
    puts ">> Body: #{response.body}" 
end
