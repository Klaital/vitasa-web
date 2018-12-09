require 'test_helper'

class SitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alamo = sites(:the_alamo)
  end

  test "should get index" do
    get sites_path,
        :headers => {
            'Accept' => 'application/json',
        }
    assert_response :success

    site_data = JSON.parse(response.body)
    assert_equal(2, site_data.length)

    # Deactivate a site, and see that it disappears from the list
    @alamo.active = false
    @alamo.save
    get sites_path,
        :headers => {
            'Accept' => 'application/json',
        }
    assert_response :success

    site_data = JSON.parse(response.body)
    assert_equal(1, site_data.length)

    # Request again, asking for deactivated sites
    get sites_path,
        :headers => {
            'Accept' => 'application/json',
        }, :params => {
            'deactivated' => 'true'
        }
    assert_response :success

    site_data = JSON.parse(response.body)
    assert_equal(2, site_data.length)

  end

  test 'site details should include site coordinator list' do
    sc1 = users(:one)
    get site_path(@alamo),
        :headers => {
            'Accept' => 'application/json',
        }
    assert_response :success

    site_data = JSON.parse(response.body)
    assert_not_nil(site_data['sitecoordinators'])

    # Add a site coordinator
    cookie = login_user('user-one', ['SiteCoordinator'])
    site_data['sitecoordinators'] << {
        'email' => sc1.email,
        'id'    => sc1.id,
    }
    put site_path(@alamo),
        :headers => {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Cookie' => cookie,
        },
        :params => site_data.to_json
    assert_response :success

    # Refetch the site data to validate
    get site_path(@alamo),
            :headers => {
                'Accept' => 'application/json',
            }
        assert_response :success

    site_data = JSON.parse(response.body)
    assert_equal(1, site_data['sitecoordinators'].length)
    assert_equal(sc1.id, site_data['sitecoordinators'][0]['id'])
  end


end
