require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
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

end
