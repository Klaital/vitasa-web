require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  test "compute signup counts" do
    user1 = users(:one) # Basic
    user2 = users(:two) # Advanced
    user3 = users(:three) # Basic

    site = sites(:the_alamo)
    calendar = site.calendars.create({:date => Date.tomorrow})
    shift = calendar.shifts.create({:start_time => Tod::TimeOfDay.new(8), :end_time => Tod::TimeOfDay.new(12,30)})

    assert_equal(0, Shift.find(shift.id).efilers_signed_up('Basic'))
    assert_equal(0, Shift.find(shift.id).efilers_signed_up('Advanced'))

    signup1 = shift.signups.create({user_id: user1.id})
    assert_equal(1, Shift.find(shift.id).efilers_signed_up('Basic'))
    assert_equal(0, Shift.find(shift.id).efilers_signed_up('Advanced'))

    signup2 = shift.signups.create({user_id: user2.id})
    assert_equal(1, Shift.find(shift.id).efilers_signed_up('Basic'))
    assert_equal(1, Shift.find(shift.id).efilers_signed_up('Advanced'))

    signup3 = shift.signups.create({user_id: user3.id})
    assert_equal(2, Shift.find(shift.id).efilers_signed_up('Basic'))
    assert_equal(1, Shift.find(shift.id).efilers_signed_up('Advanced'))

  end
  # test "the truth" do
  #   assert true
  # end
end
