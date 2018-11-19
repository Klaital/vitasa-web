class Resource < ApplicationRecord
    translates :text
    globalize_accessors
    
    validates :slug, {
        uniqueness: true,
        format: {
            with: /\A[a-z0-9-]+-?(-[a-z0-9-]+)*\z/,
            message: 'Must be a valid URL segment, using lowercase latin characters and single dashes. Leave blank to have a slug auto-generated from your sitename.'
        }
    }
end
