class PreferredSite < ApplicationRecord
  belongs_to :user
  belongs_to :site
end
