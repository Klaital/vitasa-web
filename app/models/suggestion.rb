class Suggestion < ApplicationRecord
    belongs_to :user
    
    after_initialize :init
    
    # Set default values
    def init
        self.status ||= 'Open'
    end
    
    VALID_STATUSES = %w{ Open Closed WontFix InProgress }
    validates :status, inclusion: { 
        in: VALID_STATUSES,
        message: "%{value} is not a valid suggestion status" 
    }
end
