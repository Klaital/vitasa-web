require 'test_helper'

class SitesControllerTest < ActionDispatch::IntegrationTest
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
  # HTML, Not Logged In
  #

  test "should get index" do
    get sites_url
    assert_response :success
  end

  test "should get index even with a site without a coordinator" do
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get sites_url
    assert_response :success
  end

  test "should not get new when not logged in" do
    get new_site_url
    assert_response :unauthorized
  end

  test "should not create site when not logged in" do
    assert_no_difference('Site.count') do
      post sites_url, params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    end

    assert_response :unauthorized
  end

  test "should show site" do
    get site_url(@site)
    assert_response :success
  end
  test "should show site even without a coordinator" do
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get site_url(@site)
    assert_response :success
  end


  test "should not get edit when not logged in" do
    get edit_site_url(@site)
    assert_response :unauthorized
  end

  test "should not update site when not logged in" do
    patch site_url(@site), params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    assert_response :unauthorized
  end

  test "should not destroy site when not logged in" do
    assert_no_difference('Site.count', -1) do
      delete site_url(@site)
    end

    assert_response :unauthorized
  end

  # 
  # HTML, Logged in as NewUser
  #
  test "should not get new when logged in as a NewUser" do
    
    get new_site_url
    assert_response :unauthorized
  end

  test "should not create site when logged in as a NewUser" do
    post login_path, params: {session: {email: @new_user.email, password: 'user-one-password'}}
    assert_no_difference('Site.count') do
      post sites_url, params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    end

    assert_response :unauthorized
  end

  test "should not get edit when logged in as a NewUser" do
    post login_path, params: {session: {email: @new_user.email, password: 'user-one-password'}}
    get edit_site_url(@site)
    assert_response :unauthorized
  end

  test "should not update site when logged in as a NewUser" do
    post login_path, params: {session: {email: @new_user.email, password: 'user-one-password'}}
    
    patch site_url(@site), params: { site: { city: @site.city+'a', latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    assert_equal(@site.city, Site.find(@site.id).city, 'The Site.city field was updated despite a NewUser account')
    assert_response :unauthorized
  end

  test "should not destroy site when logged in as a NewUser" do
    post login_path, params: {session: {email: @new_user.email, password: 'user-one-password'}}
    assert_no_difference('Site.count', -1) do
      delete site_url(@site)
    end

    assert_response :unauthorized
  end

  # 
  # HTML, Logged in as Admin
  #
  test "should get new when logged in as a Admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    get new_site_url
    assert_response :success
  end

  test "should  create site when logged in as a Admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    assert_difference('Site.count', 1) do
      post sites_url, params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    end

    assert_redirected_to(site_url(Site.last.id))
  end

  test "should get edit when logged in as a Admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    get edit_site_url(@site)
    assert_response :success
  end

  test "should not update site when logged in as a Admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    patch site_url(@site), params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    assert_redirected_to(site_url(@site))
  end

  test "should not destroy site when logged in as a Admin" do
    post login_path, params: {session: {email: @admin.email, password: 'user-two-password'}}
    assert_difference('Site.count', -1) do
      delete site_url(@site)
    end

    assert_redirected_to(sites_url)
  end


  # 
  # HTML, Logged in as SiteCoordinator #1
  #
  test "should not get new when logged in as a SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    get new_site_url
    assert_response :unauthorized
  end

  test "should not create site when logged in as a SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    assert_no_difference('Site.count') do
      post sites_url, params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    end

    assert_response :unauthorized
  end

  test "should get edit for an owned site when logged in as a SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    get edit_site_url(@site)
    assert_response :success
  end

  test "should not get edit for an owned site when logged in as the wrong SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    get edit_site_url(@cathedral)
    assert_response :unauthorized
  end


  test "should update site when logged in as a SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    patch site_url(@site), params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    assert_redirected_to(site_url(@site))
  end

  test "should not update site when logged in as the wrong SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    patch site_url(@cathedral), params: { site: { city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip } }
    assert :unauthorized
  end

  test "should not destroy site when logged in as a SiteCoordinator" do
    post login_path, params: {session: {email: @sc1.email, password: 'user-three-password'}}
    assert_no_difference('Site.count') do
      delete site_url(@site)
    end

    assert_response :unauthorized
  end
end
