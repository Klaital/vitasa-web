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
  end

  test "should get index" do
    get schedule_path
    assert_response :success
  end


end
