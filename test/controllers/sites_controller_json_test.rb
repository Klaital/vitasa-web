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

  test "should show site slug" do
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success

    site = JSON.load(response.body)
    assert_equal('the-alamo', site['slug'])
  end
  test "should show site Place ID" do
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success

    site = JSON.load(response.body)
    assert_equal('hIJX4k2TVVfXIYRIsTnhA-P-Rc', site['google_place_id'])
  end

  test "should show site Features" do
    @site.site_features = SiteFeature.create([{feature: 'Drop-off'}, {feature: 'MFT'}])
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success

    site = JSON.load(response.body)
    assert_equal(2, site['site_features'].length)
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


  #
  # JSON APIs, Logged In As NewUser
  #


  test "should get index when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
        password: 'user-one-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')

    # Query Under Test
    get sites_url, 
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success
  end

  test "should not get new when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    get new_site_url,
      :headers => {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
    
    assert_response :unauthorized
  end

  test "should not create site when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    assert_no_difference('Site.count') do
      post sites_url, 
        params: {
          city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
        }
    end

    assert_response :unauthorized
  end

  test "should show site when logged in via JSON to a NewUser" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end
  test "should show site even without a coordinator to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end


  test "should not get edit when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    get edit_site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :unauthorized
  end

  test "should not update site when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    patch site_url(@site), 
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
      
    assert_response :unauthorized
  end

  test "should not destroy site when logged in to a NewUser via JSON" do
    # Login
    post login_url, 
      params: {
        email: @new_user.email,
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
    
    # Query Under Test
    assert_no_difference('Site.count', -1) do
      delete site_url(@site),
        headers: {
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
      
    end

    assert_response :unauthorized
  end

  #
  # JSON APIs, Logged In As Admin
  #


  test "should get index when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')

    # Query Under Test
    get sites_url, 
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success
  end

  test "should get error from new when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get new_site_url,
      :headers => {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
    
    assert_response 406
  end

  test "should create site when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    assert_difference('Site.count', 1) do
      post sites_url, 
        params: {
          slug: "admin-create-test-slug", city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name+" new site", sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
        }
    end

    assert_response :success

    # The POST should return a body including the Site record
    site = JSON.load(response.body)
    assert_not_nil(site)
    assert_equal('admin-create-test-slug', site['slug'])
  end

  test "should create site without a slug when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    assert_difference('Site.count', 1) do
      post sites_url, 
        params: {
          city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name+" new site", sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
        }
    end

    assert_response :success
  end

  test "should show site when logged in via JSON to a Admin" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end
  test "should show site even without a coordinator to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end

  test "should not get edit when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get edit_site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response 406
  end

  test "should update site when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    patch site_url(@site), 
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
      
    assert_response :success
  end

  test "should update site via slug when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    patch site_url(@site.slug),
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
      
    assert_response :success
  end

  test "should destroy site when logged in to a Admin via JSON" do
    # Login
    post login_url, 
      params: {
        email: @admin.email,
        password: 'user-two-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    assert_difference('Site.count', -1) do
      delete site_url(@site),
        headers: {
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
      
    end

    assert_response :success
  end

  test "should set site Features as Admin" do
    # Login
    post login_url, 
    params: {
      email: @admin.email,
      password: 'user-two-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    @site.site_features = SiteFeature.create([
      {feature: 'Drop-off'}, {feature: 'MFT'}
    ])
    # Query Under Test
    assert_no_difference('Site.count') do
      patch site_url(@site), 
        params: {
          "name" => "new name",
          "site_features" => [ 'Drop-off' ]
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
    end
    assert_response :success

    site_refetch = Site.find(@site.id)
    assert_equal(1, site_refetch.site_features.length)
    assert_equal('Drop-off', site_refetch.site_features[0].feature)
  end

  test "should clear site Features as Admin" do
    # Login
    post login_url, 
    params: {
      email: @admin.email,
      password: 'user-two-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    @site.site_features = SiteFeature.create([
      {feature: 'Drop-off'}, {feature: 'MFT'}
    ])
    # Query Under Test
    assert_no_difference('Site.count') do
      patch site_url(@site), 
        params: {
          "name" => "new name",
          "site_features" => [ ]
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
    end
    assert_response :success

    site_refetch = Site.find(@site.id)
    assert_equal(0, site_refetch.site_features.length)
  end

  test "should not clear site Features when field is not set as Admin" do
    # Login
    post login_url, 
    params: {
      email: @admin.email,
      password: 'user-two-password'
    }.to_json,
    headers: {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    @site.site_features = SiteFeature.create([
      {feature: 'Drop-off'}, {feature: 'MFT'}
    ])
    # Query Under Test
    assert_no_difference('Site.count') do
      patch site_url(@site), 
        params: {
          "name" => "new name"
        }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
    end
    assert_response :success

    site_refetch = Site.find(@site.id)
    assert_equal(2, site_refetch.site_features.length)
  end

  #
  # JSON APIs, Logged In As SC
  #


  test "should get index when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')

    # Query Under Test
    get sites_url, 
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
    assert_response :success
  end

  test "should get error from new when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get new_site_url,
      :headers => {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
    
    assert_response :unauthorized
  end

  test "should not create site when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    assert_no_difference('Site.count') do
      post sites_url, 
        params: {
          city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
        }.to_json,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie,
        }
    end

    assert_response :unauthorized
  end

  test "should show site when logged in via JSON to a SC" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end
  test "should show site even without a coordinator to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    @site.sitecoordinator = nil
    @site.save
    assert_nil(Site.find(@site.id).sitecoordinator)
    get site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response :success
  end

  test "should not get edit when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    get edit_site_url(@site),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie
      }
    assert_response 406
  end

  test "should update owned site when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    patch site_url(@site), 
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
      
    assert_response :success
  end

  test "should not update someone else's owned site when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc2.email,
        password: 'user-four-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    assert_not_equal(@site.sitecoordinator, @sc2.id)
    assert(@sc2.has_role?('SiteCoordinator'))

    # Query Under Test
    patch site_url(@site), 
      params: {
        city: @site.city, latitude: @site.latitude, longitude: @site.longitude, name: @site.name, sitecoordinator: @site.sitecoordinator, sitestatus: @site.sitestatus, state: @site.state, street: @site.street, zip: @site.zip 
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Cookie' => cookie
      }
      
    assert_response :unauthorized
  end

  test "should not destroy site when logged in to a SC via JSON" do
    # Login
    post login_url, 
      params: {
        email: @sc1.email,
        password: 'user-three-password'
      }.to_json,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    assert_response :success
    # Harvest the cookie
    cookie = response.headers['Set-Cookie']
    assert_not_nil(cookie, 'No cookie harvested')
    
    # Query Under Test
    assert_no_difference('Site.count') do
      delete site_url(@site),
        headers: {
          'Accept' => 'application/json',
          'Cookie' => cookie,
        }
      
    end

    assert_response :unauthorized
  end

end
