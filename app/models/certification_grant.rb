class CertificationGrant < ApplicationRecord
  belongs_to :certification
  belongs_to :user, touch: true
end
