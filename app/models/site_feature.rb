class SiteFeature < ApplicationRecord
    belongs_to :site, touch: true

    VALID_SITE_FEATURES = %w{ Fixed Mobile InPersonTaxPrep DropOff Express MFT }
    validates :feature, inclusion: { 
        in: VALID_SITE_FEATURES,
        message: "%{value} is not a valid site feature" 
      }
    
end
