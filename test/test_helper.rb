ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def login_user(user, roles=nil)
    post login_url, 
      params: {
        email: "#{user}@example.org",
        password: "#{user}-password"
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')

    # If the caller has requested a specific set of roles, set that
    unless roles.nil?
      roles = roles.collect do |r|
        r.kind_of?(Role) ? r : Role.find_by(name: r.to_s)
      end.compact
      u = User.find_by(email: "#{user}@example.org")
      u.roles = roles
    end

    return cookie
  end
end

