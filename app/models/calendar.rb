class Calendar < ApplicationRecord
  belongs_to :site

  serialize :open, Tod::TimeOfDay
  serialize :close, Tod::TimeOfDay
end
