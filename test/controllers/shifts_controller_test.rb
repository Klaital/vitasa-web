require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @site = Site.last
    @calendar = @site.calendars.create({'date': Date.tomorrow})
    @shift = @calendar.shifts.create({'start_time': Tod::TimeOfDay.new(8,30), 'end_time': Tod::TimeOfDay.new(12,45)})
  end

  test "should get index" do
    get site_calendar_shifts_url(@site, @calendar)
    assert_response :success
  end

  test "should get new" do
    get new_site_calendar_shift_url(@site, @calendar)
    assert_response :success
  end

  test "should create shift" do
    assert_difference('Shift.count') do
      post site_calendar_shifts_url(@site.slug, @calendar), params: { 
        shift: { 
          day_of_week: @shift.day_of_week, 
          efilers_needed_advanced: @shift.efilers_needed_advanced, 
          efilers_needed_basic: @shift.efilers_needed_basic, 
          end_time: '17:30:00', 
          start_time: '09:00:00'
        } 
      }
    end
   assert_redirected_to site_calendar_shift_url(@site.slug, @calendar.id, Shift.last)
  end

  test "should show shift" do
    get site_calendar_shift_url(@site, @calendar, @shift)
    assert_response :success
  end

  test "should get edit" do
    get edit_site_calendar_shift_url(@site, @calendar, @shift)
    assert_response :success
  end

  test "should update shift" do
    patch site_calendar_shift_url(@site, @calendar, @shift), params: { shift: { calendar_id: @shift.calendar_id, day_of_week: @shift.day_of_week, efilers_needed_advanced: @shift.efilers_needed_advanced, efilers_needed_basic: @shift.efilers_needed_basic, end_time: @shift.end_time, start_time: @shift.start_time } }
    assert_redirected_to shift_url(@shift)
  end

  test "should destroy shift" do
    assert_difference('Shift.count', -1) do
      delete site_calendar_shift_url(@site, @calendar, @shift)
    end

    assert_redirected_to site_calendar_shifts_url(@site, @calendar)
  end
end
