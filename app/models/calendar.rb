class Calendar < ApplicationRecord
  belongs_to :site

  after_update do
    self.site.send_mobile_team_notification
    self.site.send_preferred_site_notification
  end
  after_create do
    self.site.send_mobile_team_notification
    self.site.send_preferred_site_notification
  end

  serialize :open, Tod::TimeOfDay
  serialize :close, Tod::TimeOfDay
end
