class Role < ApplicationRecord
    has_many :users, through: :role_grants
    has_many :role_grants
end
