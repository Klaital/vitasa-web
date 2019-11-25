require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "public cannot query org list" do
    get organizations_path, headers: {
        'Accept' => 'application/json',
    }
    assert_response :unauthorized
  end

  test "can set authcode field" do
    cookie = login_user('user-one', ['SuperAdmin'])
    put "/organizations/#{organizations(:vitasa).id}", headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Cookie': cookie,
    }, params: {
        authcode: '1234',
    }.to_json
    assert_response :success

    vita = Organization.find(organizations(:vitasa).id)
    assert_equal('1234', vita.authcode)
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

  test "admin can rename org" do
    cookie = login_user('user-one', ['Admin'])
    put "/organizations/#{users(:one).organization_id}", headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Cookie' => cookie,
    }, params: {
        'name' => 'new_name',
    }.to_json
    assert_response :success
    assert_equal('new_name', Organization.find(users(:one).organization_id).name, 'Org name did not actually update')
  end

  test "superadmin can edit org" do
    cookie = login_user('superadmin1', ['SuperAdmin'])
    put "/organizations/#{organizations(:vitasa).id}", headers: {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Cookie' => cookie,
    }, params: {
      'name' => 'new_name',
    }.to_json
    assert_response :success
  end
end
