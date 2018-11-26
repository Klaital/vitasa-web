require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = sites(:the_alamo)
    @cal1 = @site.calendars.create({
        :date => Date.today + 1,
        :is_closed => false,
        :notes => ''
      })
    @cal2 = @site.calendars.create({
        :date => Date.today + 2,
        :is_closed => true,
        :notes => ''
      })
    

    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    @new_user.roles = [ Role.find_by(name: 'Volunteer') ]

    @admin = users(:two)
    @admin.roles = [ Role.find_by(name: 'Admin') ]

    @sc1 = users(:three)
    @sc1.roles = [ Role.find_by(name: 'SiteCoordinator') ]
    @site.save
    @site.coordinators = [ @sc1 ]

    @sc2 = users(:four)
    @sc2.roles = [ Role.find_by(name: 'SiteCoordinator') ]
    @cathedral.save
    @cathedral.coordinators = [ @sc2 ]

  end

  #
  # JSON APIs, Not Logged In
  #

  test "should list calendars when not logged in" do
    get site_calendars_url(@site), 
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success
  end

  test "should get calendar override details when not logged in" do
    get site_calendar_url(@site, @cal1), 
      :headers => {
        'Accept' => 'application/json'
      }
    assert_response :success

    # Validate payload data
    cal = JSON.load(response.body)
    assert_equal(false, cal['is_closed'])
  end

  test "should not create calendar override when not logged in" do
    post site_calendars_url(@site),
      :headers => {
        'Accept' => 'application/json'
      },
      params: {
        calendar: {
          date: Date.today + 1,
          is_closed: false
        }
      }
      assert_response :unauthorized
  end

  test "should create calendar override when logged in to an Admin" do
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

    post site_calendars_url(@site),
      :params => {
        :calendar => {
          date: Date.today + 1,
          is_closed: false
        }
      },
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      }
      
      assert_response :success
  end

  test "should create calendar override when logged in to the SC" do
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

    assert_difference('Calendar.count', 1) do
      post site_calendars_url(@site),
        :headers => {
          'Accept' => 'application/json',
          'Cookie' => cookie,
        },
        params: {
          :calendar => {
            date: Date.today + 1,
            is_closed: false
          }
        }
    end
    assert_response :success
  end

  test "should not create calendar override when logged in to the wrong SC" do
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

    assert_no_difference('Calendar.count') do 
      post site_calendars_url(@site),
        :headers => {
          'Accept' => 'application/json',
          'Cookie' => cookie,
        },
        params: {
          :calendar => {
            date: Date.today + 1,
            open: Tod::TimeOfDay.new(8),
            close: Tod::TimeOfDay.new(17,15),
            is_closed: false
          }
        }
    end
    assert_response :unauthorized
  end
  
  test "should not delete calendar when not logged in" do
    assert_no_difference('Calendar.count') do
      delete site_calendar_url(@site, @cal1),
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
    end

    assert_response :unauthorized
  end

  test "should delete calendar when logged in as the SC" do
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

    assert_difference('Calendar.count', -1) do
      delete site_calendar_url(@site.slug, @cal1),
        :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => cookie
        }
        assert_response :success
    end
  end

  test "should not update calendar when not logged in" do
    put site_calendar_url(@site, @cal1),
      :headers => {
        'Accept' => 'application/json'
      },
      params: {
        :calendar => {
          :date => @cal1.date,
          :is_closed => @cal1.is_closed,
          :notes => @cal1.notes,
        }
      }
    
    assert_response :unauthorized
  end

  test "should not update calendar when logged in to the wrong SC" do
    cookie = login_user('user-four', ['SiteCoordinator'])

    put site_calendar_url(@site, @cal1),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      },
      params: {
        :calendar => {
          :date => @cal1.date,
          :is_closed => @cal1.is_closed,
          :notes => 'should not update calendar when logged in to the wrong SC',
        }
      }
    
    assert_response :unauthorized
  end

  test "should update calendar when logged in to the SC" do
    cookie = login_user('user-three')
    assert_not_nil(cookie, 'No cookie harvested')

    put site_calendar_url(@site, @cal1),
      :headers => {
        'Accept' => 'application/json',
        'Cookie' => cookie,
      },
      params: {
        :calendar => {
          :date => @cal1.date,
          :is_closed => @cal1.is_closed,
          :notes => 'should update calendar when logged in to the SC',
        }
      }
    
    assert_response :success
  end

end
