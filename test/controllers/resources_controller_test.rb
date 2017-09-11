require 'test_helper'

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resource = resources(:before_you_go)
  end

  def login_admin
    @admin = users(:one)
    @admin.roles = [ Role.find_by(name: 'Admin') ]
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-one-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    return cookie
  end

  test "should get index" do
    get resources_url
    assert_response :success
  end

  test "should not get new when not logged in" do
    get new_resource_url
    assert_response :unauthorized
  end

  test "should get new" do
    cookie = login_admin
    get new_resource_url, headers: {'Cookie': cookie}
    assert_response :success
  end

  test "should create resource" do
    cookie = login_admin
    assert_difference('Resource.count', 1) do
      post resources_url, 
            params: { resource: { slug: @resource.slug, text: @resource.text } },
            headers: { 'Cookie': cookie }
    end

    assert_redirected_to resource_url(Resource.last)
  end

  test "should create resource via JSON" do
    cookie = login_admin
    assert_difference('Resource.count', 1) do
      post resources_url, 
            params: { slug: @resource.slug, text: @resource.text }.to_json,
            headers: { 
              'Cookie': cookie,
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            }
    end

    assert_response(:success)
    # TODO: validate response schema and content
  end


  test "should not create resource when not logged in" do
    assert_no_difference('Resource.count') do
      post resources_url, params: { resource: { slug: @resource.slug, text: @resource.text } }
    end

    assert_response(:unauthorized)
  end

  test "should show resource" do
    get resource_url(@resource)
    assert_response :success
  end
  test "should show resource by slug" do
    get resource_url(@resource.slug)
    assert_response :success
  end

  test "should show resource JSON with a slug" do
    get resource_url @resource.slug, headers: {
      'Accept': 'application/json'
    }
    assert_response :success
    # TODO: validate response schema and content
  end

  test "should not get edit when not logged in" do
    get edit_resource_url(@resource.slug)
    assert_response :unauthorized
  end

  test "should get edit" do
    cookie = login_admin
    get edit_resource_url(@resource.slug), headers: { 'Cookie': cookie}
    assert_response :success
  end

  test "should not update resource when not logged in" do
    patch resource_url(@resource), params: { resource: { slug: @resource.slug, text: @resource.text } }
    assert_response :unauthorized
  end

  test "should update resource" do
    cookie = login_admin
    patch resource_url(@resource), 
            params: { resource: { slug: @resource.slug, text: @resource.text } },
            headers: { 'Cookie': cookie }
    assert_redirected_to resource_url(@resource)
  end

  test "should update resource via JSON" do
    cookie = login_admin
    patch resource_url(@resource), 
            params: { text: 'new resource text' }.to_json,
            headers: { 
              'Cookie': cookie,
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            }
    assert_response :success

    begin
      resource_update = JSON.parse(response.body)
      assert_equal('new resource text', resource_update['text'])
    rescue 
      assert(false, 'failed to parse response body as JSON')
    end

    r = Resource.find(@resource.id)
    assert_equal('new resource text', r.text)
  end


  test "should not destroy resource when not logged in" do
    assert_no_difference('Resource.count') do
      delete resource_url(@resource.slug)
    end

    assert_response :unauthorized
  end

  test "should destroy resource" do
    cookie = login_admin
    assert_difference('Resource.count', -1) do
      delete resource_url(@resource.slug), headers: {'Cookie': cookie}
    end

    assert_redirected_to resources_url
  end
end
