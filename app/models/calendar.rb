class Calendar < ApplicationRecord
    belongs_to :site
    has_many :shifts
    has_many :signups, through: :shifts
    has_many :users, through: :signups
end
