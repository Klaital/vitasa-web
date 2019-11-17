require 'test_helper'

class NotificationRegistrationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @notification_registration = notification_registrations(:one)
  end

  test "should register sms only if optin" do
    user = users(:one)
    user.phone = '555-555-1234'
    user.sms_optin = false
    user.save

    cookie = login_user('user-one')

    post notification_registrations_path, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookie,
    }, params: {
      platform: 'sms',
    }.to_json
    assert_response :bad_request

    user.sms_optin = true
    user.save

    post notification_registrations_path, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookie,
    }, params: {
        platform: 'sms',

    }.to_json
    assert_response :success

  end
  test "should get index" do
    get notification_registrations_url
    assert_response :success
  end

  test "should get new" do
    get new_notification_registration_url
    assert_response :success
  end

  test "should not create notification_registration unless logged in" do
    assert_no_difference('NotificationRegistration.count') do
      post notification_registrations_url, params: { notification_registration: { platform: @notification_registration.platform, token: @notification_registration.token, user_id: @notification_registration.user_id } }
    end

    assert_response :unauthorized
#    assert_redirected_to notification_registration_url(NotificationRegistration.last)
  end

  test "should show notification_registration" do
    get notification_registration_url(@notification_registration)
    assert_response :success
  end

  test "should not destroy notification_registration unless logged in" do
    assert_no_difference('NotificationRegistration.count', -1) do
      delete notification_registration_url(@notification_registration)
    end

    assert_response :unauthorized
  end

  test "should only have one registration per user" do
    user = User.find_by(:email => 'user-one@example.org')
    NotificationRegistration.where(user_id: user.id).destroy_all 
    assert_equal(0, NotificationRegistration.where(user_id: user.id).count)

    # Create a first registration    
    cookie = login_user('user-one')
    assert_difference('NotificationRegistration.count', 1) do
      post notification_registrations_url, 
        params: {
          platform: @notification_registration.platform,
          token: @notification_registration.token,
      }.to_json, headers: {
        'Cookie' => cookie,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end
    assert_response :success

    # Create a second registration. This should quietly overwrite the previous one.
    assert_no_difference('NotificationRegistration.count') do
      post notification_registrations_url, 
        params: {
          platform: @notification_registration.platform,
          token: @notification_registration.token,
      }.to_json, headers: {
        'Cookie' => cookie,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end
    assert_response :success
  end
end
