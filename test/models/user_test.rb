require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "create a new user" do
    user = User.new
    user.email = 'test1@example.org'
    user.password = 'wanchan'
    user.password_confirmation = 'wanchan'
    user.certification = 'SiteCoordinator'
    
    assert user.valid?
    assert user.save

    new_user = false
    user.roles.each do |role|
      if role.name == 'NewUser'
        new_user = true
        break
      end
    end
    assert(new_user, 'New User didn\'t automatically get the NewUser role')
  end

  test "admin roles should be detectable via is_admin?" do
    user = users(:two)
    user.roles = [ Role.find_by(name: 'Admin') ]
    assert(user.is_admin?, 'Fixture User-Two does not show is_admin?')
  end
end
