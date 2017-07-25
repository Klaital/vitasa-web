require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  test "create new site" do
    site = Site.new
    site.name = 'New Site'
    site.street = '300 Alamo Plaza'
    site.city = 'San Antonio'
    site.zip  = '78205'
    site.latitude = '29.425729'
    site.longitude = '-98.486277'
    site.sitestatus = 'Closed'

    assert site.valid?
    assert site.save
  end

  test 'sitestatus should validate against a list' do
    site = sites(:the_alamo)
    assert(site.valid?, 'The Alamo didn\'t start out valid from the fixture')
    site.sitestatus = 'some other status'
    assert_not(site.valid?, 'Site failed to validate against the valid Site Status list')
  end
end
