require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "admins should be able to change user roles" do
    admin = users(:one)
    user = users(:two)
    cookie = login_user('user-one', ['Admin'])
    user.roles = [Role.find_by(name: 'Volunteer')]

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

  test "should be able to create a user" do
    admin = users(:one)
    cookie = login_user('user-one', ['Admin'])
    post users_path,
         :headers => {
             'Accept' => 'application/json',
             'Content-Type' => 'application/json',
             'Cookie' => cookie,
         }, :params => {
             'email' => 'create-user-test@example.com',
             'password' => 'create-user-password',
             'password_confirmation' => 'create-user-password',
         }.to_json
    assert_response :success

    post users_path,
         :headers => {
             'Accept' => 'application/json',
             'Content-Type' => 'application/json',
             'Cookie' => cookie,
         }, :params => {
            "name" => "Fred Flintstone",
            "email" => "fred@gmail.com",
            "phone" => "123-123-1234",
            "certification" => "Basic",
            "password" => "123123123",
            "password_confirmation" => "123123123",
            "roles" => ["Mobile","Volunteer"]
        }.to_json
    assert_response :success
  end

  test 'should be able to update own phone number' do
    user = users(:one)
    cookie = login_user('user-one', ['Admin'])

    put user_path(user),
        :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Cookie' => cookie,
        }, :params => '{"id" : "4","name" : "Fred Flintstone","email" : "fred@g.c","phone" : "123-123-1234","certification" : "Basic","roles" : ["SiteCoordinator"]}'
    assert_response :success

    user_reloaded = User.find(user.id)
    assert_equal('123-123-1234', user_reloaded.phone)

    put user_path(user),
        :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Cookie' => cookie,
        }, :params => '{"id" : "4","name" : "Fred Flintstone","email" : "fred@g.c","phone" : "555-123-1234","certification" : "Basic","roles" : ["SiteCoordinator"]}'
    assert_response :success

    user_reloaded = User.find(user.id)
    assert_equal('555-123-1234', user_reloaded.phone)

    get user_path(user),
        :headers => {
            'Accept' => 'application/json',
            'Cookie' => cookie,
        }
    user_data = JSON.parse(response.body)
    assert_equal('555-123-1234', user_data['phone'])
  end

  test 'should be able to detect which users are coordinating a site' do
    user1 = users(:one)
    user2 = users(:two)
    site1 = sites(:the_alamo)

    assert(!site1.coordinators.include?(user1), "User #{user1.id} should not be on the SC list")

    site1.coordinators << user1
    assert(site1.coordinators.include?(user1), "User #{user1.id} should be on the SC list")
    assert(!site1.coordinators.include?(user2), "User #{user2.id} should not be on the SC list")
  end

  test 'should be able to set preferred sites' do
    user1 = users(:one)
    site1 = sites(:the_alamo)
    site2 = sites(:the_cathedral)

    cookie = login_user('user-one', ['Volunteer'])

    put user_path(user1),
        :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Cookie' => cookie,
        }, :params => {
            'name' => user1.name,
            'preferred_sites' => [
                site1.slug
            ]
        }.to_json

    assert_response :success

    # re-fetch to validate that the data was set
    get user_path(user1),
        :headers => {
            'Accept' => 'application/json',
            'Cookie' => cookie,
        }
    assert_response :success
    user_data = JSON.parse(response.body)
    assert_equal(1, user_data['preferred_sites'].length)
    assert_equal(site1.slug, user_data['preferred_sites'][0])
  end
end
