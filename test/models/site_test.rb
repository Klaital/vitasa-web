require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'None')
    @new_user.roles = [ user_role ]

    @admin = users(:two)
    user_role = Role.find_by(name: 'Admin')
    @admin.roles = [ user_role ]

    @volunteer = users(:volunteer_one)
    user_role = Role.find_by(name: 'Volunteer')
    @volunteer.roles = [ user_role ]

    user_role = Role.find_by(name: 'SiteCoordinator')
    @sc1 = users(:three)
    @sc1.roles = [ user_role ]
    @site.sitecoordinator = @sc1.id
    @site.save
    
    @sc2 = users(:four)
    @sc2.roles = [ user_role ]
    @cathedral.sitecoordinator = @sc2.id
    @cathedral.save
  end

  test "create new site" do
    site = Site.new
    site.name = 'New Site'
    site.street = '300 Alamo Plaza'
    site.city = 'San Antonio'
    site.zip  = '78205'
    site.latitude = '29.425729'
    site.longitude = '-98.486277'
    site.sitestatus = 'Closed'
    site.slug = 'new-site'

    assert site.valid?
    assert site.save
  end

  test "create new site with auto-slugify" do
    site = Site.new
    site.name = 'New Site'
    site.street = '300 Alamo Plaza'
    site.city = 'San Antonio'
    site.zip  = '78205'
    site.latitude = '29.425729'
    site.longitude = '-98.486277'
    site.sitestatus = 'Closed'
    # site.slug = 'new-site'

    assert_nil(site.slug)

    assert( site.valid?, 'Site is invalid without its slug set')
    assert( site.save, 'Site failed to save without a manually-set slug' )
    assert_equal('new-site', site.slug)
  end

  # TODO: re-evaluate this test. The tested functionality is not implemented at all. Did I remove it for a reason?
  # test 'sitestatus should validate against a list' do
  #   site = sites(:the_alamo)
  #   assert(site.valid?, 'The Alamo didn\'t start out valid from the fixture')
  #   site.sitestatus = 'some other status'
  #   assert_not(site.valid?, 'Site failed to validate against the valid Site Status list')
  # end
end
