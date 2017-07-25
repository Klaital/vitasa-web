class Site < ApplicationRecord
    VALID_SITE_STATUSES = %w{ Open Closed Accepting NearLimit NotAccepting }
    validates :sitestatus, inclusion: { 
            in: VALID_SITE_STATUSES,
            message: "%{value} is not a valid status. Must be one of #{VALID_SITE_STATUSES.join(', ')}" 
        }
end
