class Site < ApplicationRecord
    after_create :create_sns_topic
    after_update :send_preferred_site_notification, :send_mobile_team_notification
    after_destroy :delete_sns_topic

    has_many :calendars
    has_many :site_features
    has_and_belongs_to_many :coordinators, class_name: 'User', join_table: 'users_sites'
    has_and_belongs_to_many :preferred, class_name: 'User', join_table: 'preferred_sites'
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
      dates = (start_date..end_date).collect {|d| d.strftime("%Y-%M-%d")}
      WorkLog.where(site_id: self.id)
    end

  #
  # PUSH NOTIFICATIONS
  #

  # Send updates to anyone who has flagged this as a preferred site
  def send_preferred_site_notification
    logger.debug "Site #{self.slug} updated. Sending out push notifications via SNS"
    topic_arn = self.get_sns_topic
    sns = Aws::SNS::Client.new(region: 'us-west-2')
    message = "Site #{self.name} updated"
    response = sns.publish({
        :topic_arn => topic_arn,
        :message => {
            :default => message,
            :aps => {:alert => message},
            :gcm => {:notification => {:text => message}}.to_json
        },
        :message_structure => 'json',
    })

    if response.message_id
      logger.info "Update to #{self.slug} -- Sent Push via SNS: MessageID=#{response.message_id}"
    else
      logger.error "Update to #{self.slug} -- No message ID back from SNS"
    end
  end

  # Send updates to the mobile team if this is a mobile site
  def send_mobile_team_notification
    return true unless self.site_features.where(:feature => 'Mobile').count > 0
    logger.debug "Site #{self.slug} updated. Sending out push notifications to the Mobile Team via SNS"

    # TODO: lookup mobile team Topic
    topic_arn = 'arn:aws:sns:us-west-2:813809418199:vs-prod-sites-mobile'

    sns = Aws::SNS::Client.new(region: 'us-west-2')
    message = "Mobile Site #{self.name} updated"
    response = sns.publish({
                               :topic_arn => topic_arn,
                               :message => {
                                   :default => message,
                                   :aps => {:alert => message},
                                   :gcm => {:notification => {:text => message}}.to_json
                               }.to_json,
                               :message_structure => 'json',
                           })

    if response.message_id
      logger.info "Update to #{self.slug} -- Sent Push via SNS: MessageID=#{response.message_id}"
    else
      logger.error "Update to #{self.slug} -- No message ID back from SNS"
    end
  end

  def get_sns_topic
    if self.sns_topic.nil?
      self.create_sns_topic
    else
      self.sns_topic
    end
  end

  def create_sns_topic
    sns = Aws::SNS::Client.new(region: 'us-west-2')
    resp = sns.create_topic({
      name: "vs-site-#{Rails.env}-#{self.id}",
    })
    self.sns_topic = resp.topic_arn
    self.save
  end

  def delete_sns_topic
    return true if self.sns_topic.nil?
    sns = Aws::SNS::Client.new(region: 'us-west-2')
    resp = sns.delete_topic({
      topic_arn: self.sns_topic
    })
  end
end
