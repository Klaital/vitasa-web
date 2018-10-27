class SiteFeature < ApplicationRecord
    belongs_to :site

    VALID_SITE_FEATURES = %w{ InPersonTaxPrep DropOff Express MFT }
    validates :feature, inclusion: { 
        in: VALID_SITE_FEATURES,
        message: "%{value} is not a valid site feature" 
      }
    
end
