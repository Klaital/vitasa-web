require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  setup do
    @site = sites(:the_alamo)
    @cathedral = sites(:the_cathedral)

    @new_user = users(:one)
    user_role = Role.find_by(name: 'NewUser')
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

    @signup = signups(:one)
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

  test 'sitestatus should validate against a list' do
    site = sites(:the_alamo)
    assert(site.valid?, 'The Alamo didn\'t start out valid from the fixture')
    site.sitestatus = 'some other status'
    assert_not(site.valid?, 'Site failed to validate against the valid Site Status list')
  end

  
  test "should correctly detect when a user has signups" do
    @cathedral.signups.create([
      {
        date: Date.today + 1,
        user_id: @volunteer.id
      },
      {
        date: Date.today + 2,
        user_id: @sc2.id
      }
    ])

    assert(@cathedral.has_signup?(@volunteer, Date.today + 1))
    assert_not(@cathedral.has_signup?(@volunteer, Date.today))
  end
end
