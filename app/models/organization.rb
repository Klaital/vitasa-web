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

  after_create :create_sns_topics

  def volunteers_topic_name
    "vita-#{Rails.env}-#{self.id}-notification-volunteers"
  end
  def volunteers_topic_arn
    "arn:aws:sns:us-west-2:813809418199:#{self.volunteers_topic_name}"
  end
  def site_coordinators_topic_name
    "vita-#{Rails.env}-#{self.id}-notification-sc"
  end
  def site_coordinators_topic_arn
    "arn:aws:sns:us-west-2:813809418199:#{self.site_coordinators_topic_name}"
  end
  def role_topic_name(role_name)
    "vita-#{Rails.env}-#{self.id}-role-#{role_name.parameterize}"
  end
  def role_topic_arn(role_name)
    "arn:aws:sns:us-west-2:813809418199:#{self.role_topic_name(role_name)}"
  end
  def create_sns_topics
    topics = [
      self.volunteers_topic_name,
      self.site_coordinators_topic_name,
    ]
    Role::VALID_ROLE_NAMES.each do |role_name|
      topics << self.role_topic_name(role_name)
    end

    sns = Rails.configuration.sns
    topics.each do |topic|
      sns.create_topic({
        name: topic,
      })
    end
  end
end