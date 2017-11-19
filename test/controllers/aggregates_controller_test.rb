require 'test_helper'

class AggregatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:one) # Cert: Basic
    @user2 = users(:two) # Cert: Advanced
    @user3 = users(:three) # Cert: Basic

    @site1 = sites(:the_alamo)
    @site2 = sites(:the_cathedral)

    @site1_day1 = @site1.calendars.create({date: Date.tomorrow, is_closed: false})
    @site1_day2 = @site1.calendars.create({date: Date.tomorrow + 1, is_closed: false})

    @site1_day1_shift1 = @site1_day1.shifts.create({
      start_time: Tod::TimeOfDay.new(8), end_time: Tod::TimeOfDay.new(12),
      efilers_needed_basic: 6, efilers_needed_advanced: 3
    })
#    @site1_day1_shift2 = @site1_day1.shifts.create({
#      start_time: Tod::TimeOfDay.new(12), end_time: Tod::TimeOfDay.new(15),
#       efilers_needed_basic: 5, efilers_needed_advanced: 4
#    })
#    @site1_day1_shift3 = @site1_day1.shifts.create({
#      start_time: Tod::TimeOfDay.new(15), end_time: Tod::TimeOfDay.new(16, 30),
#      efilers_needed_basic: 6, efilers_needed_advanced: 4
#    })
    
    @user1_signup1 = @site1_day1_shift1.signups.create({
      user_id: @user1.id
    })
  end

  test "should get index" do
    get schedule_path
    assert_response :success
  end

  test "should get signup counts" do
    get schedule_path, params: {
      start: Date.tomorrow.strftime('%Y-%m-%d'), 
      end: (Date.tomorrow).strftime('%Y-%m-%d')
    }, headers: {
      'Accept': 'application/json'
    }
    assert_response :success

    schedule_view = JSON.parse(response.body)
    assert_not_nil(schedule_view, 'Schedule request did not return JSON payload')
    assert_equal(1, schedule_view.length)
    
    assert_equal(1, schedule_view.first['sites'].length)
    site_view = schedule_view.first['sites'].first
    assert_not_nil(site_view)
    assert_equal('the-alamo', site_view['slug'])

    assert_equal(1, site_view['shifts'].length)
    assert_equal(6 , site_view['shifts'].first['efilers_needed_basic'])

    assert_equal(1, site_view['shifts'].first['efilers_signed_up_basic'])
    assert_equal(0, site_view['shifts'].first['efilers_signed_up_advanced']) 
  end

end
