class RoleGrant < ApplicationRecord
  belongs_to :role
  belongs_to :user, touch: true
end
