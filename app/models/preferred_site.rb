class PreferredSite < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :site, touch: true
end
