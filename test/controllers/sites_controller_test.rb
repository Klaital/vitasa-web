require 'test_helper'

class SitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alamo = sites(:the_alamo)
  end

  test 'site details should include site coordinator list' do
    get site_path(@alamo),
        :headers => {
            'Accept' => 'application/json',
        }
    assert_response :success
  end

end
