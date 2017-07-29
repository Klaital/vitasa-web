class Site < ApplicationRecord
    VALID_SITE_STATUSES = %w{ Open Closed Accepting NearLimit NotAccepting }
    validates :sitestatus, inclusion: { 
            in: VALID_SITE_STATUSES,
            message: "%{value} is not a valid status. Must be one of #{VALID_SITE_STATUSES.join(', ')}" 
        }

    before_validation :slugify_self
    def slugify_self
        self.slug = (self.slug.nil? || self.slug.to_s.strip.empty?) ? self.name.parameterize : self.slug
    end
    validates :slug, {
        uniqueness: true,
        format: {
            with: /\A[a-z0-9-]+-?(-[a-z0-9-]+)*\z/,
            message: 'Must be a valid URL segment, using lowercase latin characters and single dashes. Leave blank to have a slug auto-generated from your sitename.'
        }
    }
end
