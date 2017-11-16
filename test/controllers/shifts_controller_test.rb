require 'test_helper'

class ShiftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shift = shifts(:one)
  end

  test "should get index" do
    get shifts_url
    assert_response :success
  end

  test "should get new" do
    get new_shift_url
    assert_response :success
  end

  test "should create shift" do
    assert_difference('Shift.count') do
      post shifts_url, params: { shift: { calendar_id: @shift.calendar_id, day_of_week: @shift.day_of_week, efilers_needed_advanced: @shift.efilers_needed_advanced, efilers_needed_basic: @shift.efilers_needed_basic, end_time: @shift.end_time, start_time: @shift.start_time } }
    end

    assert_redirected_to shift_url(Shift.last)
  end

  test "should show shift" do
    get shift_url(@shift)
    assert_response :success
  end

  test "should get edit" do
    get edit_shift_url(@shift)
    assert_response :success
  end

  test "should update shift" do
    patch shift_url(@shift), params: { shift: { calendar_id: @shift.calendar_id, day_of_week: @shift.day_of_week, efilers_needed_advanced: @shift.efilers_needed_advanced, efilers_needed_basic: @shift.efilers_needed_basic, end_time: @shift.end_time, start_time: @shift.start_time } }
    assert_redirected_to shift_url(@shift)
  end

  test "should destroy shift" do
    assert_difference('Shift.count', -1) do
      delete shift_url(@shift)
    end

    assert_redirected_to shifts_url
  end
end
