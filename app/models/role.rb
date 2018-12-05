class Role < ApplicationRecord
    has_many :users, through: :role_grants
    has_many :role_grants

    VALID_ROLE_NAMES = %w{ Mobile Volunteer SiteCoordinator SiteCoordinatorInactive Admin None }
    validates :name, inclusion: { 
            in: VALID_ROLE_NAMES,
            message: "%{value} is not a valid role name" 
        }
end
