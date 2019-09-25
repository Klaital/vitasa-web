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
      }, params: {
          name: 'superadmin can create an org',
      }.to_json
      assert_response :success
    end
  end
end