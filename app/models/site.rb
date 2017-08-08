class Site < ApplicationRecord
    has_many :calendars

    VALID_SITE_STATUSES = %w{ Accepting NearLimit NotAccepting Closed }
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

    serialize :monday_open, Tod::TimeOfDay
    serialize :monday_close, Tod::TimeOfDay
    serialize :tuesday_open, Tod::TimeOfDay
    serialize :tuesday_close, Tod::TimeOfDay
    serialize :wednesday_open, Tod::TimeOfDay
    serialize :wednesday_close, Tod::TimeOfDay
    serialize :thursday_open, Tod::TimeOfDay
    serialize :thursday_close, Tod::TimeOfDay
    serialize :friday_open, Tod::TimeOfDay
    serialize :friday_close, Tod::TimeOfDay
    serialize :saturday_open, Tod::TimeOfDay
    serialize :saturday_close, Tod::TimeOfDay
    serialize :sunday_open, Tod::TimeOfDay
    serialize :sunday_close, Tod::TimeOfDay
end
