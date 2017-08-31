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

  test "should not be able to see a list of users via JSON when not logged in" do 
    get users_url,
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end

  test "should not be able to see a list of users via JSON when logged in as a non-admin" do 
    non_admin = users(:one)
    non_admin_role = Role.find_by(name: 'NewUser')
    non_admin.roles = [ non_admin_role ]
    assert_not(non_admin.is_admin?)
    
    post login_path, params: {session: {email: non_admin.email, password: 'user-one-password'}}
    get users_url,
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end

  test "should be able to see a user list via JSON when logged in as admin" do 
    admin = users(:two)
    admin_role = Role.find_by(name: 'Admin')
    admin.roles = [ admin_role ]
    assert(admin.is_admin?)
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

  test "should not be able to see a user details page via JSON when logged in as a non-admin and not the same user" do 
    user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
    user.roles = [ user_role ]
    assert_not(user.is_admin?)
    
    post login_path, params: {session: {email: user.email, password: 'user-one-password'}}
    get user_url(users(:two).id),
      headers: {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end


  test "should be able to see a user details page via JSON when logged in as a non-admin and are the same user" do 
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
        certification: 'SiteCoordinator', phone: '4255550000'
      }.to_json,  
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success
  end
end
