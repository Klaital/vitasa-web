class Certification < ApplicationRecord
  belongs_to :organization
  validates :organization_id, presence: true
end
