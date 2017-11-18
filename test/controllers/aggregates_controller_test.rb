require 'test_helper'

class AggregatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user1 = users(:one)
    @user2 = users(:two)

    @site1 = sites(:the_alamo)
    @site2 = sites(:the_cathedral)

    @site1_day1 = @site1.calendars.create({date: Date.tomorrow, is_closed: false})
    @site1_day2 = @site1.calendars.create({date: Date.tomorrow + 1, is_closed: false})
    @site2_day1 = @site2.calendars.create({date: Date.tomorrow, is_closed: false})
    @site2_day2 = @site2.calendars.create({date: Date.tomorrow + 1, is_closed: false})

    @site1_day1_shift1 = @site1_day1.shifts.create({
      start_time: Tod::TimeOfDay.new(8), end_time: Tod::TimeOfDay.new(12),
      efilers_needed_basic: 6, efilers_needed_advanced: 3
    })
    @site1_day1_shift2 = @site1_day1.shifts.create({
      start_time: Tod::TimeOfDay.new(12), end_time: Tod::TimeOfDay.new(15),
       efilers_needed_basic: 5, efilers_needed_advanced: 4
    })
    @site1_day1_shift3 = @site1_day1.shifts.create({
      start_time: Tod::TimeOfDay.new(15), end_time: Tod::TimeOfDay.new(16, 30),
      efilers_needed_basic: 6, efilers_needed_advanced: 4
    })
  end

  test "should get index" do
    get schedule_path
    assert_response :success
  end

 
end
