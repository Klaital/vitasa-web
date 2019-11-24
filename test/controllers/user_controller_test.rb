require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest

  test "users should be able to update themselves" do
    cookie = login_user('user-one', ['Volunteer'])
    put user_path(users(:one)), headers: {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Cookie' => cookie,
    }, params: {
      email: 'a_new_email@example.org',
      password: 'new-password-123',
      password_confirmation: 'new-password-123',
    }.to_json

    assert_response :success
    u = User.find(users(:one).id)
    assert_equal('a_new_email@example.org', u.email)

  end
  test "org admins and superadmins should be able to set roles" do
    superadmin_cookie = login_user('superadmin1', ['SuperAdmin'])
    assert_not_nil(superadmin_cookie)
    assert(superadmin_cookie.length > 0)

    post users_path, headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => superadmin_cookie,
    }, params: {
        email: 'create_user_test@example.org',
        authcode: 'vitasa',
        password: 'create_user_test-password',
        password_confirmation: 'create_user_test-password',
    }.to_json

    assert_response :success


    # The user himself can't set roles
    cookie = login_user('create_user_test')
    put user_path(User.last), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        roles: ['Admin', 'Volunteer'],
    }.to_json
    assert_response :unauthorized
    assert_equal(1, User.last.roles.length, 'Roles should not have been set')

    # An admin from another org can't set roles
    cookie = login_user('create_user_test')
    put user_path(User.last), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        roles: ['Admin', 'Volunteer'],
    }.to_json
    assert_response :unauthorized
    assert_equal(1, User.last.roles.length, 'Roles should not have been set')

    # SuperAdmins can set roles
    put user_path(User.last), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => superadmin_cookie,
    }, params: {
        roles: ['Admin', 'Volunteer'],
    }.to_json
    assert_response :success
    assert_equal(2, User.last.roles.length, 'Roles should have been set')

    # Org Admins can set roles
    cookie = login_user('user-two', ['Admin'])
    put user_path(User.last), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        roles: ['Admin', 'Volunteer', 'Reviewer'],
    }.to_json
    assert_response :success
    assert_equal(3, User.last.roles.length, 'Roles should have been set')
  end

  test "creating users should allow different fields based on how they are registered" do
    # Organization ID is a required field
    # Check the happy path first
    post users_path, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    }, params: {
        authcode: 'vitasa',
        name: 'Create User Test',
        email: 'create_user_test@example.org',
        password: 'create_user_test',
        password_confirmation: 'create_user_test',
    }.to_json
    assert_response :success
    assert_equal(organizations(:vitasa).id, User.last.organization_id)

    # Try again without the org ID set, and validate failure
    post users_path, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
    }, params: {
        name: 'Create User Test',
        email: 'create_user_test2@example.org',
        password: 'create_usre_test',
        password_confirmation: 'create_usre_test',
    }.to_json

    assert_response 400
  end

  test "Logged-in users should have the Index view filtered" do
    vita_count = 0
    User.all.each do |u|
      vita_count += 1 if u.organization_id == organizations(:vitasa).id
    end
    assert(vita_count > 0, 'No VITASA sites in the fixtures')

    cookie = login_user('user-one')
    get users_path, headers: {
        'Accept' => 'application/json',
    }
    user_data = JSON.parse(response.body)
    assert_equal(vita_count, user_data.length)
  end

  test "Admins should be able to set roles" do
    cookie = login_user('user-one', ['Admin'])
    User.find(users(:two).id).roles = [ roles(:volunteer) ]
    put user_path(users(:two).id), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        roles: [ 'SiteCoordinator', 'Volunteer' ]
    }.to_json

    assert_response :success
    assert_equal(2, User.find(users(:two).id).roles.count, 'Roles not updated')
  end

  test "SuperAdmins should be able to set roles" do
    cookie = login_user('superadmin1', ['SuperAdmin'])
    User.find(users(:two).id).roles = [ roles(:volunteer) ]
    put user_path(users(:two).id), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        roles: [ 'SiteCoordinator', 'Volunteer' ]
    }.to_json

    assert_response :success
    assert_equal(2, User.find(users(:two).id).roles.count, 'Roles not updated')

    user_data = JSON.parse(response.body)
    assert_equal(2, user_data['roles'].length, 'Roles not updated in response')
  end

  test "SMS Optin should be visible on profiles" do
    cookie = login_user('user-one', ['Volunteer'])
    put user_path(users(:one).id), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        'email' => users(:one).email,
        'sms_optin' => true,
    }.to_json
    assert_response :success

    user_data = JSON.parse(response.body)
    assert_equal(true, user_data['sms_optin'], 'SMS Opt-in flag not updated')
  end

  test "should be able to update a user with Subscribe Mobile" do
    cookie = login_user('user-one', ['Volunteer'])
    put user_path(users(:one).id), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        'email' => users(:one).email,
        'subscribe_mobile' => true,
    }.to_json
    assert_response :success
    u = User.find(users(:one).id)
    assert_equal(true, u.subscribe_mobile, 'Subscribe Mobile flag was not set')

    put user_path(users(:one).id), headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        'name' => 'new test name',
        'subscribe_mobile' => false,
    }.to_json
    assert_response :success

  end

  ##
  ## Legacy
  ##

  # test "admins should be able to change user roles" do
  #   admin = users(:one)
  #   user = users(:two)
  #   cookie = login_user('user-one', ['Admin'])
  #   user.roles = [Role.find_by(name: 'Volunteer')]
  #
  #   assert(1, user.roles.length)
  #   assert('NewUser', user.roles.first.name)
  #
  #   patch user_path(user.id), params: {
  #     user: {},
  #     role_ids: [
  #       Role.find_by(name: 'Volunteer').id
  #     ]
  #   }, headers: {
  #     'Cookie': cookie,
  #   }
  #
  #   # Reload the user
  #   user_reloaded = User.find(user.id)
  #   assert_equal(1, user_reloaded.roles.length)
  #   assert_equal('Volunteer', user_reloaded.roles.first.name)
  # end
  # test "should be able to see the login form when not authenticated" do
  #   get login_url
  #   assert_response :success
  # end
  #
  # test "should not be able to see a list of users when not logged in" do
  #   get users_url
  #   assert_response :unauthorized
  # end
  #
  # test "should be able to see a user list when logged in" do
  #   admin = users(:two)
  #   admin_role = Role.find_by(name: 'Admin')
  #   admin.roles = [ admin_role ]
  #   assert(admin.is_admin?)
  #   post login_path, params: {session: {email: admin.email, password: 'user-two-password'}}
  #   get users_url
  #   assert_response :success
  # end
  #
  # test "should not be able to see a user details page when not logged in" do
  #   get user_url(users(:one).id)
  #   assert_response :unauthorized
  # end
  #
  # test "should be able to see a user detail page when logged in" do
  #   user = users(:one)
  #   user_role = Role.find_by(name: 'Volunteer')
  #   user.roles = [ user_role ]
  #
  #   post login_path, params: {session: {email: user.email, password: 'user-one-password'}}
  #   get user_url(users(:two))
  #   assert_response :success
  # end
  #
  # test "should not be able to update a user when not logged in" do
  #   user = users(:one)
  #   get edit_user_url(user.id)
  #   assert_response :unauthorized
  #
  #   patch user_url(user), params: { user: { email: 'user-one-new@example.org' } }
  #   assert_response :unauthorized
  # end
  #
  # test "should be able to create a user" do
  #   admin = users(:one)
  #   cookie = login_user('user-one', ['Admin'])
  #   post users_path,
  #        :headers => {
  #            'Accept' => 'application/json',
  #            'Content-Type' => 'application/json',
  #            'Cookie' => cookie,
  #        }, :params => {
  #            'email' => 'create-user-test@example.com',
  #            'password' => 'create-user-password',
  #            'password_confirmation' => 'create-user-password',
  #            'subscribe_mobile' => false
  #        }.to_json
  #   assert_response :success
  #
  #   post users_path,
  #        :headers => {
  #            'Accept' => 'application/json',
  #            'Content-Type' => 'application/json',
  #            'Cookie' => cookie,
  #        }, :params => {
  #           "name" => "Fred Flintstone",
  #           "email" => "fred@gmail.com",
  #           "phone" => "123-123-1234",
  #           "certification" => "Basic",
  #           "password" => "123123123",
  #           "password_confirmation" => "123123123",
  #           "roles" => ["Mobile","Volunteer"]
  #       }.to_json
  #   assert_response :success
  # end
  #
  # test 'should be able to update own phone number' do
  #   user = users(:one)
  #   cookie = login_user('user-one', ['Admin'])
  #
  #   put user_path(user),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Content-Type' => 'application/json',
  #           'Cookie' => cookie,
  #       }, :params => '{"id" : "4","name" : "Fred Flintstone","email" : "fred@g.c","phone" : "123-123-1234","certification" : "Basic","roles" : ["SiteCoordinator"]}'
  #   assert_response :success
  #
  #   user_reloaded = User.find(user.id)
  #   assert_equal('123-123-1234', user_reloaded.phone)
  #
  #   put user_path(user),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Content-Type' => 'application/json',
  #           'Cookie' => cookie,
  #       }, :params => '{"id" : "4","name" : "Fred Flintstone","email" : "fred@g.c","phone" : "555-123-1234","certification" : "Basic","roles" : ["SiteCoordinator"]}'
  #   assert_response :success
  #
  #   user_reloaded = User.find(user.id)
  #   assert_equal('555-123-1234', user_reloaded.phone)
  #
  #   get user_path(user),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Cookie' => cookie,
  #       }
  #   user_data = JSON.parse(response.body)
  #   assert_equal('555-123-1234', user_data['phone'])
  # end
  #
  # test 'should be able to detect which users are coordinating a site' do
  #   user1 = users(:one)
  #   user2 = users(:two)
  #   site1 = sites(:the_alamo)
  #
  #   assert(!site1.coordinators.include?(user1), "User #{user1.id} should not be on the SC list")
  #
  #   site1.coordinators << user1
  #   assert(site1.coordinators.include?(user1), "User #{user1.id} should be on the SC list")
  #   assert(!site1.coordinators.include?(user2), "User #{user2.id} should not be on the SC list")
  # end
  #
  # test 'should be able to set preferred sites' do
  #   user1 = users(:one)
  #   site1 = sites(:the_alamo)
  #   site2 = sites(:the_cathedral)
  #
  #   cookie = login_user('user-one', ['Volunteer'])
  #
  #   put user_path(user1),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Content-Type' => 'application/json',
  #           'Cookie' => cookie,
  #       }, :params => {
  #           'name' => user1.name,
  #           'preferred_sites' => [
  #               site1.slug
  #           ]
  #       }.to_json
  #
  #   assert_response :success
  #
  #   # re-fetch to validate that the data was set
  #   get user_path(user1),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Cookie' => cookie,
  #       }
  #   assert_response :success
  #   user_data = JSON.parse(response.body)
  #   assert_equal(1, user_data['preferred_sites'].length)
  #   assert_equal(site1.slug, user_data['preferred_sites'][0])
  # end
  #
  # test 'should be able to set subscribe_mobile' do
  #   user1 = users(:one)
  #
  #   cookie = login_user('user-one', ['Volunteer'])
  #
  #   put user_path(user1),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Content-Type' => 'application/json',
  #           'Cookie' => cookie,
  #       }, :params => <<-JSON
  #   {
  #       "name" : "vol tester mobile 5th",
  #       "email" : "voltestermobile@a.c",
  #       "phone" : "123-123-1234",
  #       "certification" : "None",
  #       "subscribe_mobile" : true,
  #       "roles" : ["Volunteer","Mobile"]
  #   }
  #   JSON
  #
  #   assert_response :success
  #
  #   # re-fetch to validate that the data was set
  #   get user_path(user1),
  #       :headers => {
  #           'Accept' => 'application/json',
  #           'Cookie' => cookie,
  #       }
  #   assert_response :success
  #   user_data = JSON.parse(response.body)
  #   assert_equal(true, user_data['subscribe_mobile'])
  # end
end
