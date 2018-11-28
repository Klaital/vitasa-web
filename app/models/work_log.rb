class WorkLog < ApplicationRecord
  belongs_to :user
  belongs_to :site
  validates :site_id, :presence => true
  validates :date, :format => { :with => /\A\d4-\d2-\d2\z/, :message => 'Must be YYYY-MM-DD' }
  validates :hours, :numericality => {:greater_than => 0}
end
