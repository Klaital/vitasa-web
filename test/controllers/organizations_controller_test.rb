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
end