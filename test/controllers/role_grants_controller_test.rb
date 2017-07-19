require 'test_helper'

class RoleGrantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @role_grant = role_grants(:one)
  end

  test "should get index" do
    get role_grants_url
    assert_response :success
  end

  test "should get new" do
    get new_role_grant_url
    assert_response :success
  end

  test "should create role_grant" do
    assert_difference('RoleGrant.count') do
      post role_grants_url, params: { role_grant: { role_id: @role_grant.role_id, user_id: @role_grant.user_id } }
    end

    assert_redirected_to role_grant_url(RoleGrant.last)
  end

  test "should show role_grant" do
    get role_grant_url(@role_grant)
    assert_response :success
  end

  test "should get edit" do
    get edit_role_grant_url(@role_grant)
    assert_response :success
  end

  test "should update role_grant" do
    patch role_grant_url(@role_grant), params: { role_grant: { role_id: @role_grant.role_id, user_id: @role_grant.user_id } }
    assert_redirected_to role_grant_url(@role_grant)
  end

  test "should destroy role_grant" do
    assert_difference('RoleGrant.count', -1) do
      delete role_grant_url(@role_grant)
    end

    assert_redirected_to role_grants_url
  end
end
