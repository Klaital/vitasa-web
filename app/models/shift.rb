class Shift < ApplicationRecord
  belongs_to :calendar
  has_many :signups
  serialize :start_time, Tod::TimeOfDay
  serialize :end_time, Tod::TimeOfDay

  # Helper method to look up the number of users of a specified certification 
  # level that have signed up to work this shift
  def efilers_signed_up(cert_level=nil)
    if cert_level.nil?
      self.signups.count
    else
      self.signups.where(:shift_id => self.id).joins(:user).where(:users => { :certification => cert_level.to_s }).count
    end
  end
end
