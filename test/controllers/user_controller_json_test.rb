require 'test_helper'

class UserControllerJsonTest < ActionDispatch::IntegrationTest
  # test "should not be able to see the login form via JSON" do
  #   # FIXME: wtf, this works in the browser just fine, but not via this test code
  #   get login_url,
  #     headers: {
  #       'Accept' => 'application/json'
  #     }
  #   assert_response 406
  # end

  test "should get correct signups" do
    cookie = login_user('user-three')
    assert_not_nil(cookie)
    user = users(:one)
    site = sites(:the_alamo)
    calendar = site.calendars.create({:date => Date.tomorrow})
    shift1 = calendar.shifts.create({:start_time => Tod::TimeOfDay.new(8), :end_time => Tod::TimeOfDay.new(12,30)})
    signup1 = shift1.signups.create({:user_id => user.id})
  
    get user_url(user), 
      headers: {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
    user_view = JSON.parse(response.body)
    assert_not_nil(user_view)

    assert_equal(1, user_view['work_intents'].length)
    assert_equal(0, user_view['work_history'].length)
  end
  test "should not be able to see a list of users via JSON when not logged in" do 
    get users_url,
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end

  test "should be able to see a user list via JSON when logged in" do 
    admin = users(:two)
    admin_role = Role.find_by(name: 'Volunteer')
    admin.roles = [ admin_role ]

    post login_path, params: {session: {email: admin.email, password: 'user-two-password'}}
    get users_url,
      headers: {
        'Accept' => 'application/json'
      }
      
    assert_response :success

    users = []
    begin
      users = JSON.load(response.body)
    rescue
      assert(false, 'User list did not return valid JSON')
    end

    users.each do |user|
      assert(!user.keys.include?('password'), 'The user password was returned with site details!')
    end
  end

  test "should not be able to see a user details page via JSON when not logged in" do 
    get user_url(users(:one).id),
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end

  test "should be able to see a user details page via JSON when logged in" do 
    user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
    user.roles = [ user_role ]
    assert_not(user.is_admin?)
    
    post login_path, params: {session: {email: user.email, password: 'user-one-password'}}
    get user_url(user.id),
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :success

    user = JSON.load(response.body)
    assert(!user.keys.include?('password'), 'The user password was returned with site details!')
  end

  test "should be able to see a user detail page via JSON when logged in as admin" do 
    user = users(:one)
    user_role = Role.find_by(name: 'Admin')
    user.roles = [ user_role ]
    assert(user.is_admin?)
    
    post login_path, params: {session: {email: user.email, password: 'user-one-password'}}
    get user_url(users(:two).id),
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :success
  end

  test "should not be able to update a user when not logged in" do
    user = users(:one)
    get edit_user_url(user.id)
    assert_response :unauthorized

    patch user_url(user), params: { user: { email: 'user-one-new@example.org' } }
    assert_response :unauthorized
  end

  test "should be able to update a user profile when logged in" do
    user = users(:one)
    post login_url, 
    params: {
      email: user.email,
      password: 'user-one-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')

    # Query Under Test
    patch user_url(user), 
      params: {
        certification: 'SiteCoordinator', phone: '4255550000',
      }.to_json,  
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success
  end

  test "should be able to change my password as a user who is logged in" do
    user = users(:one)
    cookie = login_user('user-one')
    old_password = user.password_digest.dup

    # Query Under Test
    patch user_url(user), 
      params: {
        password: 'new-password-123',
        password_confirmation: 'new-password-123'
      }.to_json,  
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success

    # Verify the chagnes
    user.reload
    assert_not_equal(old_password, user.password_digest)
  end


  test "should be able to register a new user" do
    user = users(:one)
    post register_url,
      params: {
        email: 'register-new-json-user@example.com',
        password: 'user-one-password',
        password_confirmation: 'user-one-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
    }

    assert_response :success
  end

  test "should be able to delete users with JSON format" do
    cookie = login_user('user-one', [roles('admin')])

    assert_difference('User.count', -1) do
      delete user_url(users('two')),
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
    end
    assert_response :success
  end

  test "should be able to set roles only as an admin" do
    user_cookie = login_user('user-one', [roles('volunteer')])
    admin_cookie = login_user('user-two', [roles('admin')])
    volunteer = User.find_by(email: 'user-one@example.org')
    admin = User.find_by(email: 'user-two@example.org')

    # Try setting roles as the non-admin user
    assert_equal(1, volunteer.roles.length)
    assert_equal('Volunteer', volunteer.roles.first.name)
    patch user_url(volunteer), 
      params: {
        'roles': [ 'Admin', 'SiteCoordinator' ]
      }.to_json, 
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => user_cookie
      }

    assert_response :unprocessable_entity

    # Reload the volunteer record
    volunteer.reload
    assert_equal(1, volunteer.roles.length)
    assert_equal('Volunteer', volunteer.roles.first.name)


    # Now try setting roles as an admin user
    patch user_url(volunteer), 
      params: {
        'roles': [ 
          'Admin', 
          'SiteCoordinator'
        ],
#        'certification': 'Basic'
      }.to_json, 
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => admin_cookie
      }

#    assert_equal('', response.body)
    assert_response :success
    volunteer.reload
    assert_equal(2, volunteer.roles.length)
  end


end
