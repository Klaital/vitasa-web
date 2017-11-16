class Shift < ApplicationRecord
  belongs_to :calendar
  has_many :signups
  serialize :start_time, Tod::TimeOfDay
  serialize :end_time, Tod::TimeOfDay
end
