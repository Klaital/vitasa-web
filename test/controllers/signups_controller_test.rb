require 'test_helper'

class SignupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
    @new_user.roles = [ user_role ]

    @admin = users(:two)
    user_role = Role.find_by(name: 'Admin')
    @admin.roles = [ user_role ]

    @volunteer = users(:volunteer_one)
    user_role = Role.find_by(name: 'Volunteer')
    @volunteer.roles = [ user_role ]

    user_role = Role.find_by(name: 'SiteCoordinator')
    @sc1 = users(:three)
    @sc1.roles = [ user_role ]
    @site.sitecoordinator = @sc1.id
    @site.save
    
    @sc2 = users(:four)
    @sc2.roles = [ user_role ]
    @cathedral.sitecoordinator = @sc2.id
    @cathedral.save

    @signup = signups(:one)
  end
  
  test "should get index" do
    get signups_url
    assert_response :success
  end

  test "should get new" do
    get new_signup_url
    assert_response :success
  end

  test "should create signup" do
    assert_difference('Signup.count') do
      post signups_url, params: { signup: { date: Date.today + 1, site_id: @site.id, user_id: @volunteer.id } }
    end

    assert_redirected_to signup_url(Signup.last)
  end

  test "should create signup from JSON" do
    # Login
    post login_url, 
    params: {
      email: @new_user.email,
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
    assert_difference('Signup.count', 1) do
      post signups_url, params: {
        date: Date.today + 1,
        site: @site.slug,
        user: @volunteer.id
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    assert_response :success
  end

  test "should show signup" do
    get signup_url(@signup)
    assert_response :success
  end

  test "should get edit" do
    get edit_signup_url(@signup)
    assert_response :success
  end

  test "should update signup" do
    patch signup_url(@signup), params: { signup: { date: Date.today + 2, site_id: @site.id, user_id: @volunteer.id } }
    assert_redirected_to signup_url(@signup)
  end

  test "should destroy signup" do
    assert_difference('Signup.count', -1) do
      delete signup_url(@signup)
    end

    assert_redirected_to signups_url
  end
end
