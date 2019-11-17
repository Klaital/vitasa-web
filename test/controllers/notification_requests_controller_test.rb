require 'test_helper'

class NotificationRequestsControllerTest < ActionDispatch::IntegrationTest
  def login(username='user-one', roles = nil)
    user = User.find_by(:email => "#{username}@example.org")
    assert_not_nil(user)
    user.roles = roles.map {|role_name| Role.find_by(name: role_name)} unless roles.nil?
    
    post login_url, 
	    params: {
	    	email: "#{username}@example.org",
		password: "#{username}-password",
            }.to_json,
            headers: {
	      'Content-Type' => 'application/json',
	      'Accept' => 'application/json',
	    }
    assert_response :success
    assert_response(:success, "Login failed for user #{username}") 
    response.headers['Set-Cookie']
  end
  setup do
    @notification_request = notification_requests(:one)
  end

  test "should get index" do
    get notification_requests_url
    assert_response :success
  end
  #
  # test "should not create request if logged in to a superadmin without an org" do
  #   u = users(:one)
  #   u.organization_id = nil
  #   u.save
  #   cookie = login_user('user-one', ['SuperAdmin'])
  #
  #   assert_no_difference('NotificationRequest.count') do
  #     post notification_requests_path, headers: {
  #         'Cookie' => cookie,
  #         'Accept' => 'application/json',
  #         'Content-Type' => 'application/json'
  #     }, params: {
  #         audience: @notification_request.audience,
  #         message: @notification_request.message,
  #         sent: @notification_request.sent
  #     }.to_json
  #   end
  #   assert_response :unprocessable_entity
  # end

  test "should create request if logged in" do
    u = users(:one)
    u.organization_id = organizations(:vitasa).id
    u.save
    cookie = login_user('user-one', ['Admin'])

    assert_difference('NotificationRequest.count', 1) do
      post notification_requests_path, headers: {
          'Cookie' => cookie,
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
      }, params: {
          audience: @notification_request.audience,
          message: @notification_request.message,
      }.to_json
      assert_response :success
    end

  end

  test "should not create notification_request unless logged in" do
    assert_no_difference('NotificationRequest.count') do
      post notification_requests_url, params: { notification_request: { audience: @notification_request.audience, message: @notification_request.message, sent: @notification_request.sent } }
    end

    assert_response :unauthorized
  end

  test "should show notification_request" do
    get notification_request_url(@notification_request)
    assert_response :success
  end

  test "should not update notification_request unless logged in" do
    patch notification_request_url(@notification_request), params: { notification_request: { audience: @notification_request.audience, message: @notification_request.message, sent: @notification_request.sent } }
    assert_response :unauthorized
  end

  test "should destroy notification_request when logged in" do
    assert_no_difference('NotificationRequest.count', -1) do
      delete notification_request_url(@notification_request)
    end
    assert_response :unauthorized

    cookie = login('user-two')
    assert_difference('NotificationRequest.count', -1) do
      delete notification_request_url(@notification_request), headers: {'Cookie': cookie}
    end
    assert_response :success
  end
end
