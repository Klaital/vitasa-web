require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "anyone can query org list" do
    get organizations_path, headers: {
        'Accept' => 'application/json',
    }
    assert_response :success
    org_data = JSON.parse(response.body)
    assert_equal(Organization.all.length, org_data.length, 'Incorrect org count in Index')
  end

  test "superadmin can create an org" do
    cookie = login_user('user-one', ['SuperAdmin'])
    assert_difference('Organization.count', 1) do
      post organizations_path, headers: {
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
      }, params: {
          name: 'superadmin can create an org',
      }.to_json
      assert_response :success
    end

    cookie = login_user('user-two', ['Monitor'])
    assert_no_difference('Organization.count') do
      post organizations_path, headers: {
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
      }, params: {
          name: 'only superadmin can create an org',
      }.to_json
      assert_response :unauthorized
    end
  end

  test "superadmin can destroy an org" do
    # Start by creating an org
    superadmin_cookie = login_user('user-one', ['SuperAdmin'])
    assert_difference('Organization.count', 1) do
      post organizations_path, headers: {
          'Content-Type' => 'application/json',
          'Cookie' => superadmin_cookie,
      }, params: {
          name: 'superadmin can create an org',
      }.to_json
      assert_response :success
    end

    # Validate that no one but a superadmin can destroy the org
    invalid_roles = %w[Mobile Volunteer SiteCoordinator SiteCoordinatorInactive Admin None Monitor].freeze
    invalid_roles.each do |role_name|
      cookie = login_user('user-two', [role_name])
      assert_no_difference('Organization.count', "Role #{role_name} was able to delete an Organization") do
        delete "/organizations/#{Organization.last.id}", headers: {
            'Content-Type' => 'application/json',
            'Cookie' => cookie,
        }, params: {
            name: 'only superadmin can delete an org',
        }.to_json
        assert_response :unauthorized, "Role #{role_name} was not refused when deleting an Organization"
      end
    end

    # Validate that the superadmin actually can do it
    assert_difference('Organization.count', -1, 'SuperAdmin was unable to delete an Organization') do
      delete "/organizations/#{Organization.last.id}", headers: {
          'Content-Type' => 'application/json',
          'Cookie' => superadmin_cookie,
      }, params: {
          name: 'superadmin can destroy an org',
      }.to_json
      assert_response :success
    end
  end
end