require 'test_helper'

class NotificationRegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @notification_registration = notification_registrations(:one)
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
end
