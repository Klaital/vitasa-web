require 'test_helper'

class SitesControllerJsonTest < ActionDispatch::IntegrationTest
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
    @new_user.roles = [ user_role ]

    @admin = users(:two)
    user_role = Role.find_by(name: 'Admin')
    @admin.roles = [ user_role ]

    user_role = Role.find_by(name: 'SiteCoordinator')
    @sc1 = users(:three)
    @sc1.roles = [ user_role ]
    @site.sitecoordinator = @sc1.id
    @site.save
    
    @sc2 = users(:four)
    @sc2.roles = [ user_role ]
    @cathedral.sitecoordinator = @sc2.id
    @cathedral.save
  end

  #
  # JSON APIs, Not Logged In
  #


  test "should get index even with a site without a coordinator" do
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get sites_url, 
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success
  end

  test "should not get new when not logged in" do
    get new_site_url,
      :headers => {
        'Accept' => 'application/json'
      }
    
    assert_response :unauthorized
  end

  test "should not create site when not logged in" do
    assert_no_difference('Site.count') do
      post sites_url, 
        params: {
          city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
    end

    assert_response :unauthorized
  end

  test "should show site" do
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success
  end
  test "should show site even without a coordinator" do
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success
  end


  test "should not get edit when not logged in" do
    get edit_site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :unauthorized
  end

  test "should not update site when not logged in" do
    patch site_url(@site), 
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
      
    assert_response :unauthorized
  end

  test "should not destroy site when not logged in" do
    assert_no_difference('Site.count', -1) do
      delete site_url(@site),
        headers: {
          'Accept' => 'application/json',
        }
      
    end

    assert_response :unauthorized
  end

end
