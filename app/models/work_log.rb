class WorkLog < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :site, touch: true

  validates :site_id, :presence => true
  validates :date, :format => { :with => /\A\d{4}-\d{2}-\d{2}\z/, :message => 'Must be YYYY-MM-DD' }
  validates :hours, :numericality => {:greater_than => 0}
end
