require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "admins should be able to change user roles" do
    admin = users(:one)
    user = users(:two)
    cookie = login_user('user-one', ['Admin'])
    user.roles = [Role.find_by(name: 'NewUser')]

    assert(1, user.roles.length)
    assert('NewUser', user.roles.first.name)

    patch user_path(user.id), params: { 
      user: {},
      role_ids: [
        Role.find_by(name: 'Volunteer').id
      ]
    }, headers: {
      'Cookie': cookie,
    }

    # Reload the user
    user_reloaded = User.find(user.id)
    assert_equal(1, user_reloaded.roles.length)
    assert_equal('Volunteer', user_reloaded.roles.first.name)
  end
  test "should be able to see the login form when not authenticated" do
    get login_url
    assert_response :success
  end

  test "should not be able to see a list of users when not logged in" do 
    get users_url
    assert_response :unauthorized
  end

  test "should be able to see a user list when logged in" do 
    admin = users(:two)
    admin_role = Role.find_by(name: 'Admin')
    admin.roles = [ admin_role ]
    assert(admin.is_admin?)
    post login_path, params: {session: {email: admin.email, password: 'user-two-password'}}
    get users_url
    assert_response :success
  end

  test "should not be able to see a user details page when not logged in" do 
    get user_url(users(:one).id)
    assert_response :unauthorized
  end

  test "should be able to see a user detail page when logged in" do 
    user = users(:one)
    user_role = Role.find_by(name: 'Volunteer')
    user.roles = [ user_role ]
    
    post login_path, params: {session: {email: user.email, password: 'user-one-password'}}
    get user_url(users(:two))
    assert_response :success
  end

  test "should not be able to update a user when not logged in" do
    user = users(:one)
    get edit_user_url(user.id)
    assert_response :unauthorized

    patch user_url(user), params: { user: { email: 'user-one-new@example.org' } }
    assert_response :unauthorized
  end

  test "should be able to see Site details for Coordinators' sites" do
    user = users(:one)
    user.roles = [ Role.find_by(name: 'Admin') ]
    site1 = sites(:the_alamo)
    site1.sitecoordinator = user.id
    site1.save
    site2 = sites(:the_cathedral)
    site2.backup_coordinator_id = user.id
    site2.save

    post login_path, 
          params: {
            email: user.email, password: 'user-one-password'
          }.to_json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          }
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
      
    get user_path(user),
          headers: {
            'Accept': 'application/json'
          }
    assert_response :success

    user_data = JSON.parse(response.body)
    assert_equal(2, user_data['sites_coordinated'].length)
    assert_equal('The Alamo', user_data['sites_coordinated'][1]['name'])
    assert_equal('the-alamo', user_data['sites_coordinated'][1]['slug'])
  end

end
