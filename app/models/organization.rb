class Organization < ApplicationRecord# Invalidate the user's cache
  has_many :users
  has_many :sites
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