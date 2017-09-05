require 'net/http'
require 'json'
require 'logger'
require 'date'

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
user_profile = JSON.parse(response.body)
user_id = user_profile['id']
puts ">> Body: #{response.body}"

if response.code !~ /[23]\d\d/
    exit(0)
end

puts "> Get Site #1"
uri = URI("http://#{host}/sites/cody-library")
request = Net::HTTP::Get.new uri
request['Accept'] = 'application/json'

response = http.request(request)

puts ">> Got #{response.code} #{response.message}"
puts ">> Body: #{response.body}" if response['Content-Type'] == 'application/json'

if response.code != '200'
    exit(0)
end

puts "> Create Signup"
uri = URI("http://#{host}/signups")
request = Net::HTTP::Post.new uri
request['Cookie'] = session_cookie
request['Accept'] = 'application/json'
request['Content-Type'] = 'application/json'
request.body = {
    "date": Date.today + 1,
    "user": user_id,
    "site": 'cody-library'
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
