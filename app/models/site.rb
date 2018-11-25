class Site < ApplicationRecord
    has_many :calendars
    has_many :site_features
    has_and_belongs_to_many :coordinators, class_name: 'User', join_table: 'users_sites'
    
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

    def has_feature?(feature)
        self.site_features.each do |site_feature|
            return true if site_feature.feature == feature
        end
        return false
    end

    def work_history(start_date = Date.today - 7, end_date = Date.today - 1)
      WorkLog.where(site_id: self.id, start_time: start_date..end_date)
    end
end
